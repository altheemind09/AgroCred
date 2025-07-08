;; Agricultural Professional Registry Smart Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-disclosure (err u104))

;; Disclosure levels
(define-constant DISCLOSURE-PUBLIC u0)
(define-constant DISCLOSURE-CERTIFIED-FARMERS u1)
(define-constant DISCLOSURE-CONFIDENTIAL u2)

;; Data Variables
(define-data-var agriculture-fee uint u200) ;; 0.02% fee in basis points

;; Data Maps

;; Farmer profiles
(define-map farmer-profiles
  { farmer: principal }
  {
    farmer-name: (string-ascii 100),
    crop-specializations: (string-ascii 200),
    farm-region: (string-ascii 100),
    profile-disclosure: uint,
    established-at: uint,
    is-certified: bool
  }
)

;; Harvest records
(define-map harvest-records
  { farmer: principal, harvest-id: uint }
  {
    crop-variety: (string-ascii 100),
    farming-method: (string-ascii 100),
    harvest-date: uint,
    planting-date: (optional uint),
    yield-notes: (string-ascii 500),
    disclosure-level: uint,
    logged-at: uint
  }
)

;; Farmer harvest counters
(define-map farmer-harvest-count
  { farmer: principal }
  { count: uint }
)

;; Agricultural certifications
(define-map agricultural-certifications
  { farmer: principal, certification-id: uint }
  {
    cert-program: (string-ascii 100),
    certifying-agency: (string-ascii 100),
    certified-date: uint,
    expiration-date: (optional uint),
    cert-hash: (buff 32),
    disclosure-level: uint,
    is-verified: bool,
    logged-at: uint
  }
)

;; Farmer certification counters
(define-map farmer-certification-count
  { farmer: principal }
  { count: uint }
)

;; Farming endorsements
(define-map farming-endorsements
  { farmer: principal, endorsement-id: uint }
  {
    expertise-area: (string-ascii 50),
    endorsing-farmer: principal,
    endorsement-details: (string-ascii 300),
    endorsed-at: uint
  }
)

;; Farmer endorsement counters
(define-map farmer-endorsement-count
  { farmer: principal }
  { count: uint }
)

;; Cooperative partnerships
(define-map cooperative-partnerships
  { farmer1: principal, farmer2: principal }
  {
    partnership-status: (string-ascii 20), ;; "pending", "active", "dissolved"
    initiated-by: principal,
    formed-at: uint
  }
)

;; Expertise area endorsement counts
(define-map expertise-endorsements
  { farmer: principal, expertise: (string-ascii 50) }
  { count: uint }
)

;; Read-only functions

;; Get farmer profile
(define-read-only (get-farmer-profile (farmer principal))
  (map-get? farmer-profiles { farmer: farmer })
)

;; Get harvest record
(define-read-only (get-harvest-record (farmer principal) (harvest-id uint))
  (map-get? harvest-records { farmer: farmer, harvest-id: harvest-id })
)

;; Get agricultural certification
(define-read-only (get-agricultural-certification (farmer principal) (certification-id uint))
  (map-get? agricultural-certifications { farmer: farmer, certification-id: certification-id })
)

;; Get farming endorsement
(define-read-only (get-farming-endorsement (farmer principal) (endorsement-id uint))
  (map-get? farming-endorsements { farmer: farmer, endorsement-id: endorsement-id })
)

;; Get partnership status
(define-read-only (get-partnership-status (farmer1 principal) (farmer2 principal))
  (map-get? cooperative-partnerships { farmer1: farmer1, farmer2: farmer2 })
)

;; Get expertise endorsement count
(define-read-only (get-expertise-endorsement-count (farmer principal) (expertise (string-ascii 50)))
  (default-to u0 (get count (map-get? expertise-endorsements { farmer: farmer, expertise: expertise })))
)

;; Check if farmers are partners
(define-read-only (are-farmers-partners (farmer1 principal) (farmer2 principal))
  (let ((partnership1 (map-get? cooperative-partnerships { farmer1: farmer1, farmer2: farmer2 }))
        (partnership2 (map-get? cooperative-partnerships { farmer1: farmer2, farmer2: farmer1 })))
    (or
      (and (is-some partnership1) (is-eq (get partnership-status (unwrap-panic partnership1)) "active"))
      (and (is-some partnership2) (is-eq (get partnership-status (unwrap-panic partnership2)) "active"))
    )
  )
)

;; Check if farmer can view confidential content
(define-read-only (can-view-confidential-content (owner principal) (viewer principal) (disclosure-level uint))
  (or
    (is-eq owner viewer)
    (is-eq disclosure-level DISCLOSURE-PUBLIC)
    (and 
      (is-eq disclosure-level DISCLOSURE-CERTIFIED-FARMERS)
      (are-farmers-partners owner viewer)
    )
  )
)

;; Public functions

;; Register farmer profile
(define-public (register-farmer-profile (farmer-name (string-ascii 100)) (crop-specializations (string-ascii 200)) (farm-region (string-ascii 100)) (profile-disclosure uint))
  (begin
    (asserts! (<= profile-disclosure DISCLOSURE-CONFIDENTIAL) err-invalid-disclosure)
    (ok (map-set farmer-profiles
      { farmer: tx-sender }
      {
        farmer-name: farmer-name,
        crop-specializations: crop-specializations,
        farm-region: farm-region,
        profile-disclosure: profile-disclosure,
        established-at: block-height,
        is-certified: false
      }
    ))
  )
)

;; Log harvest record
(define-public (log-harvest-record (crop-variety (string-ascii 100)) (farming-method (string-ascii 100)) (harvest-date uint) (planting-date (optional uint)) (yield-notes (string-ascii 500)) (disclosure-level uint))
  (let ((current-count (default-to u0 (get count (map-get? farmer-harvest-count { farmer: tx-sender })))))
    (begin
      (asserts! (<= disclosure-level DISCLOSURE-CONFIDENTIAL) err-invalid-disclosure)
      (map-set harvest-records
        { farmer: tx-sender, harvest-id: current-count }
        {
          crop-variety: crop-variety,
          farming-method: farming-method,
          harvest-date: harvest-date,
          planting-date: planting-date,
          yield-notes: yield-notes,
          disclosure-level: disclosure-level,
          logged-at: block-height
        }
      )
      (map-set farmer-harvest-count
        { farmer: tx-sender }
        { count: (+ current-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Add agricultural certification
(define-public (add-agricultural-certification (cert-program (string-ascii 100)) (certifying-agency (string-ascii 100)) (certified-date uint) (expiration-date (optional uint)) (cert-hash (buff 32)) (disclosure-level uint))
  (let ((current-count (default-to u0 (get count (map-get? farmer-certification-count { farmer: tx-sender })))))
    (begin
      (asserts! (<= disclosure-level DISCLOSURE-CONFIDENTIAL) err-invalid-disclosure)
      (map-set agricultural-certifications
        { farmer: tx-sender, certification-id: current-count }
        {
          cert-program: cert-program,
          certifying-agency: certifying-agency,
          certified-date: certified-date,
          expiration-date: expiration-date,
          cert-hash: cert-hash,
          disclosure-level: disclosure-level,
          is-verified: false,
          logged-at: block-height
        }
      )
      (map-set farmer-certification-count
        { farmer: tx-sender }
        { count: (+ current-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Send partnership request
(define-public (send-partnership-request (target-farmer principal))
  (begin
    (asserts! (not (is-eq tx-sender target-farmer)) err-unauthorized)
    (asserts! (is-none (map-get? cooperative-partnerships { farmer1: tx-sender, farmer2: target-farmer })) err-already-exists)
    (asserts! (is-none (map-get? cooperative-partnerships { farmer1: target-farmer, farmer2: tx-sender })) err-already-exists)
    (ok (map-set cooperative-partnerships
      { farmer1: tx-sender, farmer2: target-farmer }
      {
        partnership-status: "pending",
        initiated-by: tx-sender,
        formed-at: block-height
      }
    ))
  )
)

;; Accept partnership request
(define-public (accept-partnership-request (requesting-farmer principal))
  (let ((partnership (map-get? cooperative-partnerships { farmer1: requesting-farmer, farmer2: tx-sender })))
    (begin
      (asserts! (is-some partnership) err-not-found)
      (asserts! (is-eq (get partnership-status (unwrap-panic partnership)) "pending") err-unauthorized)
      (ok (map-set cooperative-partnerships
        { farmer1: requesting-farmer, farmer2: tx-sender }
        {
          partnership-status: "active",
          initiated-by: requesting-farmer,
          formed-at: (get formed-at (unwrap-panic partnership))
        }
      ))
    )
  )
)

;; Provide farming endorsement
(define-public (provide-farming-endorsement (farmer principal) (expertise-area (string-ascii 50)) (endorsement-details (string-ascii 300)))
  (let ((current-count (default-to u0 (get count (map-get? farmer-endorsement-count { farmer: farmer }))))
        (current-expertise-count (default-to u0 (get count (map-get? expertise-endorsements { farmer: farmer, expertise: expertise-area })))))
    (begin
      (asserts! (not (is-eq tx-sender farmer)) err-unauthorized)
      (asserts! (are-farmers-partners tx-sender farmer) err-unauthorized)
      (map-set farming-endorsements
        { farmer: farmer, endorsement-id: current-count }
        {
          expertise-area: expertise-area,
          endorsing-farmer: tx-sender,
          endorsement-details: endorsement-details,
          endorsed-at: block-height
        }
      )
      (map-set farmer-endorsement-count
        { farmer: farmer }
        { count: (+ current-count u1) }
      )
      (map-set expertise-endorsements
        { farmer: farmer, expertise: expertise-area }
        { count: (+ current-expertise-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Verify agricultural certification (admin only)
(define-public (verify-agricultural-certification (farmer principal) (certification-id uint))
  (let ((certification (map-get? agricultural-certifications { farmer: farmer, certification-id: certification-id })))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some certification) err-not-found)
      (ok (map-set agricultural-certifications
        { farmer: farmer, certification-id: certification-id }
        (merge (unwrap-panic certification) { is-verified: true })
      ))
    )
  )
)

;; Certify farmer (admin only)
(define-public (certify-farmer (farmer principal))
  (let ((profile (map-get? farmer-profiles { farmer: farmer })))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some profile) err-not-found)
      (ok (map-set farmer-profiles
        { farmer: farmer }
        (merge (unwrap-panic profile) { is-certified: true })
      ))
    )
  )
)

;; Update agriculture fee (admin only)
(define-public (update-agriculture-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set agriculture-fee new-fee)
    (ok true)
  )
)