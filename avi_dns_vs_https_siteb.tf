## avi data objects
data "avi_applicationprofile" "system-dns" {
	name	= "System-DNS"
}
data "avi_networkprofile" "system-udp-per-pkt" {
	name	= "System-UDP-Per-Pkt"
}

## create the avi dns vip
resource "avi_vsvip" "dnsvsvip" {
	name		= "${var.dns_vs_name}-vip"
	tenant_ref	= data.avi_tenant.admin.id
	cloud_ref	= data.avi_cloud.nsxt_cloud.id
	tier1_lr        = data.nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path

	# static vip IP address
	vip {
		vip_id = "0"
		ip_address {
			type = "V4"
			addr = var.dns_vs_address
		}
	}
}

resource "avi_virtualservice" "dns_vs" {
	name			= var.dns_vs_name
	tenant_ref		= data.avi_tenant.admin.id
	cloud_ref		= data.avi_cloud.nsxt_cloud.id
	vsvip_ref		= avi_vsvip.dnsvsvip.id
	application_profile_ref	= data.avi_applicationprofile.system-dns.id
	network_profile_ref	= data.avi_networkprofile.system-udp-per-pkt.id
	se_group_ref		= data.avi_serviceenginegroup.serviceenginegroup.id
        services {
                 port           = 53
        }
        enabled			= true
        analytics_policy {
          all_headers           = true
          significant_log_throttle = 0
          udf_log_throttle         = 0

          full_client_logs {
            duration = 0
            enabled  = true
            throttle = 0
          }

         metrics_realtime_update {
         duration = 0
         enabled  = true
         }
       }
}
