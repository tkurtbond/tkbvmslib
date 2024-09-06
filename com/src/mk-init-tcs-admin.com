$ sedit "s/%{?+}$/$ @com_src:initial-tcs-checkin $1" <t:src.lis >t:x.com
