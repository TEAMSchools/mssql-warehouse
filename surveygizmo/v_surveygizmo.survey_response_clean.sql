USE gabby;

GO
CREATE OR ALTER VIEW
  surveygizmo.survey_response_clean AS
SELECT
  cur.survey_response_id,
  cur.survey_id,
  cur.contact_id,
  cur.[status],
  cur.is_test_data,
  cur.datetime_started,
  cur.datetime_submitted,
  cur.date_started,
  cur.date_submitted,
  cur.response_time,
  cur.city,
  cur.postal,
  cur.region,
  cur.country,
  cur.latitude,
  cur.longitude,
  cur.dma,
  cur.[language],
  cur.ip_address,
  cur.link_id,
  cur.referer,
  cur.session_id,
  cur.user_agent,
  cur.url_privatedomain,
  cur.url_contact,
  cur.url_messageid,
  cur.url_sguid,
  cur.url_pathdata,
  cur.data_quality_json,
  cur.survey_data_json
FROM
  gabby.surveygizmo.survey_response_clean_current_static cur
UNION ALL
SELECT
  rcv.survey_response_id,
  rcv.survey_id,
  rcv.contact_id,
  rcv.[status],
  rcv.is_test_data,
  rcv.datetime_started,
  rcv.datetime_submitted,
  rcv.date_started,
  rcv.date_submitted,
  rcv.response_time,
  rcv.city,
  rcv.postal,
  rcv.region,
  rcv.country,
  rcv.latitude,
  rcv.longitude,
  rcv.dma,
  rcv.[language],
  rcv.ip_address,
  rcv.link_id,
  rcv.referer,
  rcv.session_id,
  rcv.user_agent,
  rcv.url_privatedomain,
  rcv.url_contact,
  rcv.url_messageid,
  rcv.url_sguid,
  rcv.url_pathdata,
  rcv.data_quality_json,
  rcv.survey_data_json
FROM
  gabby.surveygizmo.survey_response_clean_archive rcv
