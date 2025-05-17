;; Reporting Contract
;; Generates authenticated sustainability disclosures

(define-data-var admin principal tx-sender)

;; Report data structure
(define-map reports
  { report-id: (string-ascii 36) }
  {
    resource-id: (string-ascii 36),
    report-type: (string-ascii 32),
    period-start: uint,
    period-end: uint,
    created-by: principal,
    created-at: uint,
    hash: (buff 32),
    verified: bool,
    verified-by: (optional principal),
    verified-at: (optional uint)
  }
)

;; Report metrics structure
(define-map report-metrics
  { report-id: (string-ascii 36) }
  {
    extracted-amount: uint,
    replenished-amount: uint,
    sustainability-score: uint,
    certifications-count: uint
  }
)

;; Create a new report
(define-public (create-report
    (report-id (string-ascii 36))
    (resource-id (string-ascii 36))
    (report-type (string-ascii 32))
    (period-start uint)
    (period-end uint)
    (hash (buff 32))
    (extracted-amount uint)
    (replenished-amount uint)
    (sustainability-score uint)
    (certifications-count uint))
  (begin
    (asserts! (>= period-end period-start) (err u400))

    ;; Record the report
    (map-insert reports
      { report-id: report-id }
      {
        resource-id: resource-id,
        report-type: report-type,
        period-start: period-start,
        period-end: period-end,
        created-by: tx-sender,
        created-at: block-height,
        hash: hash,
        verified: false,
        verified-by: none,
        verified-at: none
      }
    )

    ;; Record the report metrics
    (map-insert report-metrics
      { report-id: report-id }
      {
        extracted-amount: extracted-amount,
        replenished-amount: replenished-amount,
        sustainability-score: sustainability-score,
        certifications-count: certifications-count
      }
    )

    (ok true)
  )
)

;; Verify a report
(define-public (verify-report (report-id (string-ascii 36)))
  (let ((report (unwrap! (map-get? reports { report-id: report-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set reports
      { report-id: report-id }
      (merge report {
        verified: true,
        verified-by: (some tx-sender),
        verified-at: (some block-height)
      })
    )
    (ok true)
  )
)

;; Get report details
(define-read-only (get-report (report-id (string-ascii 36)))
  (map-get? reports { report-id: report-id })
)

;; Get report metrics
(define-read-only (get-report-metrics (report-id (string-ascii 36)))
  (map-get? report-metrics { report-id: report-id })
)

;; Set a new admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
