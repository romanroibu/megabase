-- This migration fixes an issue where unverified MFA factors can accumulate
-- when a user starts the MFA enrollment process but doesn't finish it (by verifying).
-- If a user hits the limit of unverified MFA factors, they are no longer able to enroll a new one.
--
-- The solution is to remove other unverified factors when a new one is enrolled.

create or replace function public.remove_other_unverified_mfa_factors() 
returns trigger as $$
begin
  delete from auth.mfa_factors
  where status = 'unverified'
  and user_id = new.user_id
  and id != new.id;
  return new;
end;
$$ language plpgsql security invoker;

create or replace trigger remove_other_unverified_mfa_factors_trigger
  after insert on auth.mfa_factors
  for each row execute procedure public.remove_other_unverified_mfa_factors();
