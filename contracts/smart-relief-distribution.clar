(define-constant ERR_UNAUTHORIZED u401)
(define-constant ERR_BENEFICIARY_NOT_FOUND u402)
(define-constant ERR_ALREADY_REGISTERED u403)
(define-constant ERR_INSUFFICIENT_FUNDS u404)
(define-constant ERR_INVALID_AMOUNT u405)
(define-constant ERR_DISTRIBUTION_CLOSED u406)
(define-constant ERR_ALREADY_RECEIVED u407)
(define-constant ERR_INVALID_CATEGORY u408)
(define-constant ERR_CAMPAIGN_NOT_FOUND u409)
(define-constant ERR_INVALID_PERIOD u410)

(define-constant BENEFICIARY_STATUS_PENDING u0)
(define-constant BENEFICIARY_STATUS_VERIFIED u1)
(define-constant BENEFICIARY_STATUS_REJECTED u2)
(define-constant BENEFICIARY_STATUS_SUSPENDED u3)

(define-constant AID_CATEGORY_EMERGENCY u0)
(define-constant AID_CATEGORY_FOOD u1)
(define-constant AID_CATEGORY_MEDICAL u2)
(define-constant AID_CATEGORY_HOUSING u3)
(define-constant AID_CATEGORY_EDUCATION u4)

(define-constant CAMPAIGN_STATUS_ACTIVE u0)
(define-constant CAMPAIGN_STATUS_PAUSED u1)
(define-constant CAMPAIGN_STATUS_CLOSED u2)

(define-constant MIN_DONATION_AMOUNT u100000)
(define-constant VERIFICATION_PERIOD u1440)
(define-constant DISTRIBUTION_PERIOD u144)

(define-data-var beneficiary-counter uint u0)
(define-data-var campaign-counter uint u0)
(define-data-var total-donations uint u0)
(define-data-var total-distributed uint u0)
(define-data-var contract-admin principal tx-sender)

(define-map beneficiaries principal {
    beneficiary-id: uint,
    name: (string-ascii 100),
    location: (string-ascii 100),
    category: uint,
    registration-date: uint,
    verification-date: (optional uint),
    status: uint,
    total-received: uint,
    last-distribution-date: (optional uint),
    verifier: (optional principal)
})

(define-map relief-campaigns uint {
    campaign-id: uint,
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    category: uint,
    target-amount: uint,
    current-amount: uint,
    beneficiary-count: uint,
    status: uint,
    start-date: uint,
    end-date: uint,
    distribution-per-beneficiary: uint
})

(define-map donations { campaign-id: uint, donor: principal } {
    total-donated: uint,
    first-donation-date: uint,
    last-donation-date: uint,
    donation-count: uint
})

(define-map distributions { campaign-id: uint, beneficiary: principal } {
    amount-received: uint,
    distribution-date: uint,
    distributor: principal
})

(define-map campaign-beneficiaries { campaign-id: uint, beneficiary: principal } {
    registered-date: uint,
    eligible: bool,
    priority-score: uint
})

(define-map donor-profiles principal {
    total-donated: uint,
    campaigns-supported: uint,
    first-donation-date: uint,
    reputation-score: uint
})

(define-map verifier-approvals principal {
    approved-by: principal,
    approval-date: uint,
    is-active: bool
})

(define-public (register-beneficiary (name (string-ascii 100)) (location (string-ascii 100)) (category uint))
    (let (
        (beneficiary-id (+ (var-get beneficiary-counter) u1))
    )
        (asserts! (is-none (map-get? beneficiaries tx-sender)) (err ERR_ALREADY_REGISTERED))
        (asserts! (<= category AID_CATEGORY_EDUCATION) (err ERR_INVALID_CATEGORY))
        
        (map-set beneficiaries tx-sender {
            beneficiary-id: beneficiary-id,
            name: name,
            location: location,
            category: category,
            registration-date: burn-block-height,
            verification-date: none,
            status: BENEFICIARY_STATUS_PENDING,
            total-received: u0,
            last-distribution-date: none,
            verifier: none
        })
        
        (var-set beneficiary-counter beneficiary-id)
        (ok beneficiary-id)
    )
)

(define-public (verify-beneficiary (beneficiary-principal principal) (approved bool))
    (let (
        (beneficiary (unwrap! (map-get? beneficiaries beneficiary-principal) (err ERR_BENEFICIARY_NOT_FOUND)))
        (verifier-approval (map-get? verifier-approvals tx-sender))
    )
        (asserts! (is-some verifier-approval) (err ERR_UNAUTHORIZED))
        (asserts! (get is-active (unwrap! verifier-approval (err ERR_UNAUTHORIZED))) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status beneficiary) BENEFICIARY_STATUS_PENDING) (err ERR_ALREADY_REGISTERED))
        
        (map-set beneficiaries beneficiary-principal (merge beneficiary {
            status: (if approved BENEFICIARY_STATUS_VERIFIED BENEFICIARY_STATUS_REJECTED),
            verification-date: (some burn-block-height),
            verifier: (some tx-sender)
        }))
        
        (ok approved)
    )
)

(define-public (create-relief-campaign (title (string-ascii 100)) (description (string-ascii 500)) (category uint) (target-amount uint) (end-date uint) (distribution-per-beneficiary uint))
    (let (
        (campaign-id (+ (var-get campaign-counter) u1))
    )
        (asserts! (> target-amount u0) (err ERR_INVALID_AMOUNT))
        (asserts! (> end-date burn-block-height) (err ERR_INVALID_PERIOD))
        (asserts! (> distribution-per-beneficiary u0) (err ERR_INVALID_AMOUNT))
        (asserts! (<= category AID_CATEGORY_EDUCATION) (err ERR_INVALID_CATEGORY))
        
        (map-set relief-campaigns campaign-id {
            campaign-id: campaign-id,
            creator: tx-sender,
            title: title,
            description: description,
            category: category,
            target-amount: target-amount,
            current-amount: u0,
            beneficiary-count: u0,
            status: CAMPAIGN_STATUS_ACTIVE,
            start-date: burn-block-height,
            end-date: end-date,
            distribution-per-beneficiary: distribution-per-beneficiary
        })
        
        (var-set campaign-counter campaign-id)
        (ok campaign-id)
    )
)

(define-public (donate-to-campaign (campaign-id uint) (amount uint))
    (let (
        (campaign (unwrap! (map-get? relief-campaigns campaign-id) (err ERR_CAMPAIGN_NOT_FOUND)))
        (existing-donation (default-to { total-donated: u0, first-donation-date: burn-block-height, last-donation-date: burn-block-height, donation-count: u0 }
                           (map-get? donations { campaign-id: campaign-id, donor: tx-sender })))
    )
        (asserts! (>= amount MIN_DONATION_AMOUNT) (err ERR_INVALID_AMOUNT))
        (asserts! (is-eq (get status campaign) CAMPAIGN_STATUS_ACTIVE) (err ERR_DISTRIBUTION_CLOSED))
        (asserts! (< burn-block-height (get end-date campaign)) (err ERR_INVALID_PERIOD))
        
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        (map-set donations { campaign-id: campaign-id, donor: tx-sender } {
            total-donated: (+ (get total-donated existing-donation) amount),
            first-donation-date: (get first-donation-date existing-donation),
            last-donation-date: burn-block-height,
            donation-count: (+ (get donation-count existing-donation) u1)
        })
        
        (map-set relief-campaigns campaign-id (merge campaign {
            current-amount: (+ (get current-amount campaign) amount)
        }))
        
        (var-set total-donations (+ (var-get total-donations) amount))
        (update-donor-profile tx-sender amount)
        (ok true)
    )
)

(define-public (register-for-campaign (campaign-id uint))
    (let (
        (campaign (unwrap! (map-get? relief-campaigns campaign-id) (err ERR_CAMPAIGN_NOT_FOUND)))
        (beneficiary (unwrap! (map-get? beneficiaries tx-sender) (err ERR_BENEFICIARY_NOT_FOUND)))
    )
        (asserts! (is-eq (get status beneficiary) BENEFICIARY_STATUS_VERIFIED) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status campaign) CAMPAIGN_STATUS_ACTIVE) (err ERR_DISTRIBUTION_CLOSED))
        (asserts! (is-none (map-get? campaign-beneficiaries { campaign-id: campaign-id, beneficiary: tx-sender })) (err ERR_ALREADY_REGISTERED))
        
        (map-set campaign-beneficiaries { campaign-id: campaign-id, beneficiary: tx-sender } {
            registered-date: burn-block-height,
            eligible: true,
            priority-score: (calculate-priority-score (get category beneficiary) (get registration-date beneficiary))
        })
        
        (map-set relief-campaigns campaign-id (merge campaign {
            beneficiary-count: (+ (get beneficiary-count campaign) u1)
        }))
        
        (ok true)
    )
)

(define-public (distribute-aid (campaign-id uint) (beneficiary-principal principal))
    (let (
        (campaign (unwrap! (map-get? relief-campaigns campaign-id) (err ERR_CAMPAIGN_NOT_FOUND)))
        (beneficiary (unwrap! (map-get? beneficiaries beneficiary-principal) (err ERR_BENEFICIARY_NOT_FOUND)))
        (campaign-beneficiary (unwrap! (map-get? campaign-beneficiaries { campaign-id: campaign-id, beneficiary: beneficiary-principal }) (err ERR_BENEFICIARY_NOT_FOUND)))
        (distribution-amount (get distribution-per-beneficiary campaign))
    )
        (asserts! (is-eq tx-sender (get creator campaign)) (err ERR_UNAUTHORIZED))
        (asserts! (get eligible campaign-beneficiary) (err ERR_UNAUTHORIZED))
        (asserts! (is-none (map-get? distributions { campaign-id: campaign-id, beneficiary: beneficiary-principal })) (err ERR_ALREADY_RECEIVED))
        (asserts! (>= (get current-amount campaign) distribution-amount) (err ERR_INSUFFICIENT_FUNDS))
        
        (try! (as-contract (stx-transfer? distribution-amount tx-sender beneficiary-principal)))
        
        (map-set distributions { campaign-id: campaign-id, beneficiary: beneficiary-principal } {
            amount-received: distribution-amount,
            distribution-date: burn-block-height,
            distributor: tx-sender
        })
        
        (map-set beneficiaries beneficiary-principal (merge beneficiary {
            total-received: (+ (get total-received beneficiary) distribution-amount),
            last-distribution-date: (some burn-block-height)
        }))
        
        (map-set relief-campaigns campaign-id (merge campaign {
            current-amount: (- (get current-amount campaign) distribution-amount)
        }))
        
        (var-set total-distributed (+ (var-get total-distributed) distribution-amount))
        (ok true)
    )
)

(define-public (approve-verifier (verifier-principal principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (map-set verifier-approvals verifier-principal {
            approved-by: tx-sender,
            approval-date: burn-block-height,
            is-active: true
        })
        (ok true)
    )
)

(define-public (suspend-beneficiary (beneficiary-principal principal))
    (let (
        (beneficiary (unwrap! (map-get? beneficiaries beneficiary-principal) (err ERR_BENEFICIARY_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (map-set beneficiaries beneficiary-principal (merge beneficiary { status: BENEFICIARY_STATUS_SUSPENDED }))
        (ok true)
    )
)

(define-public (close-campaign (campaign-id uint))
    (let (
        (campaign (unwrap! (map-get? relief-campaigns campaign-id) (err ERR_CAMPAIGN_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (get creator campaign)) (err ERR_UNAUTHORIZED))
        (map-set relief-campaigns campaign-id (merge campaign { status: CAMPAIGN_STATUS_CLOSED }))
        (ok true)
    )
)

(define-public (emergency-withdraw (campaign-id uint))
    (let (
        (campaign (unwrap! (map-get? relief-campaigns campaign-id) (err ERR_CAMPAIGN_NOT_FOUND)))
        (remaining-amount (get current-amount campaign))
    )
        (asserts! (is-eq tx-sender (var-get contract-admin)) (err ERR_UNAUTHORIZED))
        (asserts! (> remaining-amount u0) (err ERR_INSUFFICIENT_FUNDS))
        
        (try! (as-contract (stx-transfer? remaining-amount tx-sender tx-sender)))
        (map-set relief-campaigns campaign-id (merge campaign { 
            current-amount: u0,
            status: CAMPAIGN_STATUS_CLOSED 
        }))
        (ok remaining-amount)
    )
)

(define-private (calculate-priority-score (category uint) (registration-date uint))
    (let (
        (days-since-registration (/ (- burn-block-height registration-date) u144))
    )
        (+ (* category u10) (if (<= days-since-registration u50) days-since-registration u50))
    )
)

(define-private (update-donor-profile (donor principal) (amount uint))
    (let (
        (existing-profile (default-to { total-donated: u0, campaigns-supported: u0, first-donation-date: burn-block-height, reputation-score: u0 }
                          (map-get? donor-profiles donor)))
    )
        (map-set donor-profiles donor {
            total-donated: (+ (get total-donated existing-profile) amount),
            campaigns-supported: (+ (get campaigns-supported existing-profile) u1),
            first-donation-date: (get first-donation-date existing-profile),
            reputation-score: (let ((new-score (+ (get reputation-score existing-profile) u5))) (if (<= new-score u100) new-score u100))
        })
        true
    )
)

(define-read-only (get-beneficiary (beneficiary-principal principal))
    (map-get? beneficiaries beneficiary-principal)
)

(define-read-only (get-campaign (campaign-id uint))
    (map-get? relief-campaigns campaign-id)
)

(define-read-only (get-donation (campaign-id uint) (donor principal))
    (map-get? donations { campaign-id: campaign-id, donor: donor })
)

(define-read-only (get-distribution (campaign-id uint) (beneficiary principal))
    (map-get? distributions { campaign-id: campaign-id, beneficiary: beneficiary })
)

(define-read-only (get-campaign-beneficiary (campaign-id uint) (beneficiary principal))
    (map-get? campaign-beneficiaries { campaign-id: campaign-id, beneficiary: beneficiary })
)

(define-read-only (get-donor-profile (donor principal))
    (map-get? donor-profiles donor)
)

(define-read-only (is-verifier-approved (verifier principal))
    (match (map-get? verifier-approvals verifier)
        approval (get is-active approval)
        false
    )
)

(define-read-only (get-campaign-stats (campaign-id uint))
    (match (map-get? relief-campaigns campaign-id)
        campaign (some {
            funding-progress: (if (> (get target-amount campaign) u0)
                               (/ (* (get current-amount campaign) u100) (get target-amount campaign))
                               u0),
            days-remaining: (if (> (get end-date campaign) burn-block-height)
                             (/ (- (get end-date campaign) burn-block-height) u144)
                             u0),
            beneficiaries-registered: (get beneficiary-count campaign),
            current-funding: (get current-amount campaign),
            is-active: (is-eq (get status campaign) CAMPAIGN_STATUS_ACTIVE)
        })
        none
    )
)

(define-read-only (get-contract-stats)
    {
        total-beneficiaries: (var-get beneficiary-counter),
        total-campaigns: (var-get campaign-counter),
        total-donations: (var-get total-donations),
        total-distributed: (var-get total-distributed),
        contract-admin: (var-get contract-admin),
        remaining-funds: (- (var-get total-donations) (var-get total-distributed))
    }
)