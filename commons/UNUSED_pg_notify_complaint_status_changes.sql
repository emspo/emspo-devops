-- POSTGRESQL script to notify about complaint status changes

CREATE OR REPLACE FUNCTION fn_pg_notify_complaint_status_changes()
RETURNS trigger AS $$
DECLARE
    payload JSON;
BEGIN
    SELECT * INTO STRICT complainant_detail FROM user WHERE uuid = NEW.complainant;

    payload = json_build_object(
        'subject', format('Complaint Status Update: %s, Ref No %s', NEW.status, NEW.complaint_id),
        'body', 'Dear ' || complainant_detail.first_name || ' ' || complainant_detail.last_name || ',\n\n' ||
                'Your complaint with reference number ' || NEW.complaint_id || ' has been updated to status: ' || NEW.status || '.\n\n' ||
                'Thank you for your patience.\n\nBest regards,\nThe Support Team',
        'to', complainant_detail.email
    );
    PERFORM pg_notify('complaint_status_changes', payload::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_pg_notify_complaint_status_changes
AFTER INSERT ON complaints
FOR EACH ROW EXECUTE FUNCTION fn_pg_notify_complaint_status_changes();