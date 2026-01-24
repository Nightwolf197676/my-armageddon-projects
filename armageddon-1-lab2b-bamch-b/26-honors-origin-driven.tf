# # ############################################
# # Lab 2B-Honors - A) /api/public-feed = origin-driven caching
# # ############################################

# # Explanation: Public feed is cacheable—but only if the origin explicitly says so.
# # Uses managed policy that honors Cache-Control s-maxage from origin (e.g. s-maxage=30 → 30s cache)
# ordered_cache_behavior {
#   path_pattern           = "/api/public-feed"
#   target_origin_id       = "${var.project_name}-alb-origin01"
#   viewer_protocol_policy = "redirect-to-https"

#   allowed_methods = ["GET", "HEAD", "OPTIONS"]
#   cached_methods  = ["GET", "HEAD"]

#   # Honor Cache-Control from origin (min TTL=0 so it respects s-maxage=30 exactly)
#   cache_policy_id = data.aws_cloudfront_cache_policy.bos_use_origin_cache_headers01.id

#   # Forward viewer context safely to origin (cookies, query strings, most headers except viewer Host)
#   origin_request_policy_id = data.aws_cloudfront_origin_request_policy.bos_orp_all_viewer_except_host01.id
# }

# # ############################################
# # Lab 2B-Honors - B) /api/* = safe default (no caching)
# # ############################################

# # Explanation: Everything else under /api is dangerous by default—disable caching unless overridden by more specific rule above.
# ordered_cache_behavior {
#   path_pattern           = "/api/*"
#   target_origin_id       = "${var.project_name}-alb-origin01"
#   viewer_protocol_policy = "redirect-to-https"

#   allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#   cached_methods  = ["GET", "HEAD"]

#   cache_policy_id          = aws_cloudfront_cache_policy.bos_cache_api_disabled01.id
#   origin_request_policy_id = aws_cloudfront_origin_request_policy.bos_orp_api01.id
# }