create or replace view analysis.visit_events as
  select s.session_id, s.user_id, s.app, s.platform, s.browser, s.source, s.screen_w,
         s.is_test, s.is_synthetic, s.started_at,
         e.kind, e.id, e.step, e.overlay, e.x, e.y, e.seq, e.hit,
         e.label, e.value, e.duration_ms, e.account, e.created_at
  from public.sessions s
  join (
    select 'click' as kind, id, session_id, step, overlay, x, y, seq, hit,
           null::text as label, null::text as value, null::integer as duration_ms,
           null::text as account, created_at
    from public.clicks
    union all
    select 'choice', id, session_id, step, null, null, null, null, null,
           label, value, duration_ms, null, created_at
    from public.selections
    union all
    select 'sign-in', id, session_id, null, null, null, null, null, null,
           null, null, null, account, created_at
    from public.identities
  ) e using (session_id);

comment on view analysis.visit_events is
  'We list every click, choice and sign-in of a visit, one row each, from clicks, selections and identities, with all their columns and the visit''s own details from sessions, excluding nothing, so one visit can be replayed oldest first.';
