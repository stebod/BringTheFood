//
//  NSNotificationCenterKeys.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 03/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation

// rest notifications - "DONATIONS" section
public let donationCreatedNotificationKey = "donationCreatedResponse"
public let donationDeletedNotificationKey = "donationDeletedResponse"
public let getSingleDonationNotificationKey = "getSingleDonationResponse"
public let getOthersDonationNotificationKey = "getOthersDonationResponse"
public let getMyDonationNotificationKey = "getMyDonationResponse"

// rest notifications - "BOOKINGS" section
public let getBookingsNotificationKey = "getBookingsReponse"
public let getCollectorOfDonationNotificationKey = "getCollectorOfDonationReponse"
public let bookingCreatedNotificationKey = "boookingCreatedResponse"
public let unbookedNotificationKey = "boookingDeletedResponse"
public let bookingCollectedNotificationKey = "boookingCollectedResponse"

// rest notifications - "USER" section
public let loginResponseNotificationKey = "loginResponse"
public let createUserNotificationKey = "userCreatedResponse"
public let logoutResponseNotificationKey = "logoutResponse"
public let mailAvailabilityResponseNotificationKey = "mailAvailabilityResponse"
public let userInfoResponseNotificationKey = "userInfoResponse"
public let getSettingsResponseNotificationKey = "getSettingsResponse"
public let settingsUpdatedNotificationKey = "settingsUpdatedResponse"
public let passwordChangedNotificationKey = "passwordChangedResponse"

// rest notifications - "NOTIFICATIONS" section
public let getNotificationsResponseNotificationKey = "getNotificationsResponse"

// ImageDownloader
public let imageDownloadNotificationKey = "imageDownload"

// LocationAutocompleter
public let locationAutocompletedNotificationKey = "locationAutocompleted"