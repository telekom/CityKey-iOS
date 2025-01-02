//
// Cities.swift
//
// This file was automatically generated and should not be edited.
//

#if canImport(Intents)

import Intents

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *) @available(tvOS, unavailable)
@objc(Cities)
public class Cities: INObject {

    @available(iOS 13.0, macOS 11.0, watchOS 6.0, *)
    @NSManaged public var cityId: NSNumber?

    @available(iOS 13.0, macOS 11.0, watchOS 6.0, *)
    @NSManaged public var cityName: String?

    override public class var supportsSecureCoding: Bool { true }

}

@available(iOS 13.0, macOS 11.0, watchOS 6.0, *) @available(tvOS, unavailable)
@objc(CitiesResolutionResult)
public class CitiesResolutionResult: INObjectResolutionResult {

    // This resolution result is for when the app extension wants to tell Siri to proceed, with a given Cities. The resolvedValue can be different than the original Cities. This allows app extensions to apply business logic constraints.
    // Use notRequired() to continue with a 'nil' value.
    @objc(successWithResolvedCities:)
    public class func success(with resolvedObject: Cities) -> Self {
        return super.success(with: resolvedObject)
    }

    // This resolution result is to ask Siri to disambiguate between the provided Cities.
    @objc(disambiguationWithCitiessToDisambiguate:)
    public class func disambiguation(with objectsToDisambiguate: [Cities]) -> Self {
        return super.disambiguation(with: objectsToDisambiguate)
    }

    // This resolution result is to ask Siri to confirm if this is the value with which the user wants to continue.
    @objc(confirmationRequiredWithCitiesToConfirm:)
    public class func confirmationRequired(with objectToConfirm: Cities?) -> Self {
        return super.confirmationRequired(with: objectToConfirm)
    }

    @available(*, unavailable)
    override public class func success(with resolvedObject: INObject) -> Self {
        fatalError()
    }

    @available(*, unavailable)
    override public class func disambiguation(with objectsToDisambiguate: [INObject]) -> Self {
        fatalError()
    }

    @available(*, unavailable)
    override public class func confirmationRequired(with objectToConfirm: INObject?) -> Self {
        fatalError()
    }

}

#endif
