INSERT INTO organisation (id, name, active, created_at, updated_at, organisation_type, can_approve_own_go_live_requests)
VALUES (gen_random_uuid (), 'Worth Local', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'central', true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO domain (domain, organisation_id)
VALUES ('worth.systems', (SELECT id FROM organisation WHERE name='Worth Local'))
ON CONFLICT (domain) DO NOTHING;

UPDATE service_sms_senders SET sms_sender = 'WORTHLOCAL';

UPDATE provider_details SET active = false WHERE identifier = 'mmg';

UPDATE provider_details SET supports_international = true WHERE identifier = 'firetext';

