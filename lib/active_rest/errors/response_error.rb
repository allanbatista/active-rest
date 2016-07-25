module ActiveRest
  module Error
    def self.by_response response
      message = ActiveRest::Response.messages(response.status)

      case response.status
        when 400 then BadRequest.new(message, response)
        when 401 then Unauthorized.new(message, response)
        when 402 then PaymentRequired.new(message, response)
        when 403 then Forbidden.new(message, response)
        when 404 then NotFound.new(message, response)
        when 405 then MethodNotAllowed.new(message, response)
        when 406 then NotAcceptable.new(message, response)
        when 407 then ProxyAuthenticationRequired.new(message, response)
        when 408 then RequestTimeout.new(message, response)
        when 409 then Conflict.new(message, response)
        when 410 then Gone.new(message, response)
        when 411 then LengthRequired.new(message, response)
        when 412 then PreconditionFailed.new(message, response)
        when 413 then PayloadTooLarge.new(message, response)
        when 414 then URITooLong.new(message, response)
        when 415 then UnsupportedMediaType.new(message, response)
        when 416 then RangeNotSatisfiable.new(message, response)
        when 417 then ExpectationFailed.new(message, response)
        when 418 then IMaTeapot.new(message, response)
        when 421 then MisdirectedRequest.new(message, response)
        when 422 then UnprocessableEntity.new(message, response)
        when 423 then Locked.new(message, response)
        when 424 then FailedDependency.new(message, response)
        when 426 then UpgradeRequired.new(message, response)
        when 428 then PreconditionRequired.new(message, response)
        when 429 then TooManyRequests.new(message, response)
        when 431 then RequestHeaderFieldsTooLarge.new(message, response)
        when 451 then UnavailableForLegalReasons.new(message, response)
        when 500 then InternalServerError.new(message, response)
        when 501 then NotImplemented.new(message, response)
        when 502 then BadGateway.new(message, response)
        when 503 then ServiceUnavailable.new(message, response)
        when 504 then GatewayTimeout.new(message, response)
        when 505 then HTTPVersionNotSupported.new(message, response)
        when 506 then VariantAlsoNegotiates.new(message, response)
        when 507 then InsufficientStorage.new(message, response)
        when 508 then LoopDetected.new(message, response)
        when 510 then NotExtended.new(message, response)
        when 511 then NetworkAuthenticationRequired.new(message, response)
        else ResponseError.new("ResponseError unkown", response)
      end
    end

    class ResponseError < StandardError
      attr_reader :status, :response

      def initialize message, response
        @status   = response.status
        @response = response
        super(message)
      end
    end

    ##
    # Errors with status 400..499
    class NotFound < ResponseError
    end
    
    class BadRequest < ResponseError
    end

    class Unauthorized < ResponseError
    end

    class PaymentRequired < ResponseError
    end

    class Forbidden < ResponseError
    end

    class NotFound < ResponseError
    end

    class MethodNotAllowed < ResponseError
    end

    class NotAcceptable < ResponseError
    end

    class ProxyAuthenticationRequired < ResponseError
    end

    class RequestTimeout < ResponseError
    end

    class Conflict < ResponseError
    end

    class Gone < ResponseError
    end

    class LengthRequired < ResponseError
    end

    class PreconditionFailed < ResponseError
    end

    class PayloadTooLarge < ResponseError
    end

    class URITooLong < ResponseError
    end

    class UnsupportedMediaType < ResponseError
    end

    class RangeNotSatisfiable < ResponseError
    end

    class ExpectationFailed < ResponseError
    end

    class IMaTeapot < ResponseError
    end

    class MisdirectedRequest < ResponseError
    end

    class UnprocessableEntity < ResponseError
    end

    class Locked < ResponseError
    end

    class FailedDependency < ResponseError
    end

    class UpgradeRequired < ResponseError
    end

    class PreconditionRequired < ResponseError
    end

    class TooManyRequests < ResponseError
    end

    class RequestHeaderFieldsTooLarge < ResponseError
    end

    class UnavailableForLegalReasons < ResponseError
    end

    ##
    # Errors with status 500..599
    class InternalServerError < ResponseError
    end

    class NotImplemented < ResponseError
    end

    class BadGateway < ResponseError
    end

    class ServiceUnavailable < ResponseError
    end

    class GatewayTimeout < ResponseError
    end

    class HTTPVersionNotSupported < ResponseError
    end

    class VariantAlsoNegotiates < ResponseError
    end

    class InsufficientStorage < ResponseError
    end

    class LoopDetected < ResponseError
    end

    class NotExtended < ResponseError
    end

    class NetworkAuthenticationRequired < ResponseError
    end

  end
end