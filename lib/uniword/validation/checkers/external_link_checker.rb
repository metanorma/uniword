# frozen_string_literal: true

require 'net/http'
require 'uri'
# LinkChecker autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Checkers
      # Validates external HTTP/HTTPS links.
      #
      # Responsibility: Validate external URLs are accessible.
      # Single Responsibility: External link validation only.
      #
      # Performs HTTP requests to verify:
      # - URL is accessible
      # - Response status is acceptable
      # - Follows redirects if configured
      #
      # Configuration options:
      # - timeout: Request timeout in seconds
      # - retry_count: Number of retries on failure
      # - retry_delay: Delay between retries in seconds
      # - allowed_status_codes: HTTP status codes considered valid
      # - follow_redirects: Whether to follow redirects
      # - max_redirects: Maximum number of redirects to follow
      # - check_ssl: Whether to verify SSL certificates
      # - user_agent: User agent string for requests
      #
      # @example Create and use checker
      #   checker = ExternalLinkChecker.new(config: {
      #     timeout: 10,
      #     retry_count: 3
      #   })
      #   result = checker.check(hyperlink)
      class ExternalLinkChecker < LinkChecker
        # Default configuration values
        DEFAULTS = {
          timeout: 10,
          retry_count: 3,
          retry_delay: 1,
          allowed_status_codes: [200, 201, 301, 302, 303, 307, 308],
          follow_redirects: true,
          max_redirects: 5,
          check_ssl: true,
          user_agent: 'Uniword Link Validator/1.0'
        }.freeze

        # Check if this checker can validate the given link.
        #
        # @param link [Object] The link to check
        # @return [Boolean] true if link has an HTTP/HTTPS URL
        #
        # @example
        #   checker.can_check?(hyperlink) # => true
        def can_check?(link)
          return false unless enabled?
          return false unless link.respond_to?(:url)

          url = link.url
          url&.to_s&.match?(%r{^https?://})
        end

        # Validate the external link.
        #
        # @param link [Object] The link to validate
        # @param document [Object] The document (unused for external links)
        # @return [ValidationResult] The validation result
        #
        # @example
        #   result = checker.check(hyperlink)
        def check(link, _document = nil)
          return ValidationResult.unknown(link, 'Checker disabled') unless enabled?

          url = link.url
          retry_count = config_value(:retry_count, DEFAULTS[:retry_count])

          # Attempt with retries
          last_error = nil
          (retry_count + 1).times do |attempt|
            return perform_check(url, link)
          rescue StandardError => e
            last_error = e
            sleep(config_value(:retry_delay, DEFAULTS[:retry_delay])) if attempt < retry_count
          end

          # All retries failed
          ValidationResult.failure(
            link,
            "Failed to connect after #{retry_count + 1} attempts: #{last_error.message}",
            metadata: { error: last_error.class.name }
          )
        end

        private

        # Perform the actual HTTP check.
        #
        # @param url_string [String] The URL to check
        # @param link [Object] The link object
        # @return [ValidationResult] The validation result
        def perform_check(url_string, link)
          uri = URI.parse(url_string)
          redirects_followed = 0
          max_redirects = config_value(:max_redirects, DEFAULTS[:max_redirects])

          loop do
            response = make_request(uri)
            status_code = response.code.to_i

            # Check if status is allowed
            allowed_codes = config_value(:allowed_status_codes, DEFAULTS[:allowed_status_codes])
            unless allowed_codes.include?(status_code)
              return ValidationResult.failure(
                link,
                "HTTP #{status_code}: #{response.message}",
                metadata: { status_code: status_code }
              )
            end

            # Handle redirects
            if redirect?(status_code)
              redirects_followed += 1

              if redirects_followed > max_redirects
                return ValidationResult.failure(
                  link,
                  "Too many redirects (#{redirects_followed})",
                  metadata: { redirects: redirects_followed }
                )
              end

              unless config_value(:follow_redirects, DEFAULTS[:follow_redirects])
                return ValidationResult.warning(
                  link,
                  "Redirect detected: #{status_code} to #{response['location']}",
                  metadata: { status_code: status_code, location: response['location'] }
                )
              end

              # Follow redirect
              location = response['location']
              uri = URI.parse(location)
              next
            end

            # Success
            metadata = { status_code: status_code }
            metadata[:redirects] = redirects_followed if redirects_followed.positive?

            return ValidationResult.success(link, metadata: metadata)
          end
        rescue URI::InvalidURIError => e
          ValidationResult.failure(link, "Invalid URL: #{e.message}")
        rescue SocketError => e
          ValidationResult.failure(link, "Host not found: #{e.message}")
        rescue Timeout::Error
          ValidationResult.failure(link, 'Request timeout')
        rescue StandardError => e
          ValidationResult.failure(
            link,
            "Connection error: #{e.message}",
            metadata: { error: e.class.name }
          )
        end

        # Make HTTP request.
        #
        # @param uri [URI] The URI to request
        # @return [Net::HTTPResponse] The response
        def make_request(uri)
          timeout = config_value(:timeout, DEFAULTS[:timeout])
          check_ssl = config_value(:check_ssl, DEFAULTS[:check_ssl])
          user_agent = config_value(:user_agent, DEFAULTS[:user_agent])

          Net::HTTP.start(
            uri.host,
            uri.port,
            use_ssl: uri.scheme == 'https',
            verify_mode: check_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
            open_timeout: timeout,
            read_timeout: timeout
          ) do |http|
            request = Net::HTTP::Head.new(uri.request_uri)
            request['User-Agent'] = user_agent
            http.request(request)
          end
        end

        # Check if status code is a redirect.
        #
        # @param status_code [Integer] HTTP status code
        # @return [Boolean] true if redirect
        def redirect?(status_code)
          [301, 302, 303, 307, 308].include?(status_code)
        end
      end
    end
  end
end
