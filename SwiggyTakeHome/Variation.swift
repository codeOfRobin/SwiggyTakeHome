//
//  Variation.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

struct Variation: Decodable {
	let name: String
	let price: Int
//	let `default`: Bool //is an Int on the API 🤷‍♀️
	let id: String
//	let inStock: Bool //is an Int on the API 🤷‍♀️
//	let isVeg: Bool?
}

struct VariantGroup: Decodable {
//	let groupID: String
	let name: String
	let variations: [Variation]
}

struct Exclusion: Decodable {
//	let groupID: String
	let variationID: String


}

struct Variant: Decodable {
	let variantGroups: [VariantGroup]
	let exclusions: [Exclusion]

	enum CodingKeys: String, CodingKey {
		case variantGroups
		case exclusions = "exclude_list"
	}

}

struct APIResponse: Decodable {
	let variants: Variant
}
