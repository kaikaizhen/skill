# Brief — Clinic Scheduling Platform

We are replacing the scheduling system used across our clinic network. This will
go live for real patients.

## Actors

- **Patients** book, reschedule, and cancel their own appointments.
- **Practitioners** manage their availability and see their own schedule.
- **Clinic administrators** manage practitioners, rooms, and clinic hours, and can
  act on behalf of a patient.
- **Network administrators** manage clinics and view cross-clinic reporting.

## Scope

- Appointment booking with room and practitioner double-booking prevention.
- Recurring availability rules with per-clinic timezone handling and holiday
  calendars.
- Cancellation policy: patient-initiated cancellations within 24 hours incur a
  fee; the fee is waived for practitioner-initiated cancellations.
- Patient records include medical notes. Access is restricted to the treating
  practitioner and clinic administrators; access is audited.
- Notifications by email and SMS, with retry and delivery tracking.
- Data must be retained for 7 years and be exportable on patient request.
- Integration with the existing billing system (REST) and the lab results feed
  (SFTP batch).
- Migration of 4 years of existing appointment history from the legacy database.

## Non-functional

- Must handle 200 concurrent bookings during the Monday morning peak.
- Audit log for every access to a patient record.
- Regional data residency requirements apply.
