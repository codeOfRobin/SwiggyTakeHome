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

//	enum CodingKeys: String, CodingKey {
//		case name
//		case price
//		case id
//	}

}

struct VariantGroup: Decodable {
	let groupID: String
	let name: String
	let variations: [Variation]

	enum CodingKeys: String, CodingKey {
		case groupID = "group_id"
		case name
		case variations
	}

//	init(from decoder: Decoder) throws {
//		let values = try decoder.container(keyedBy: CodingKeys.self)
//		groupID = try values.decode(String.self, forKey: .groupID)
//		name = try values.decode(String.self, forKey: .name)
//		variations = try values.decode([Variation].self, forKey: .variations)
//	}
}

struct Exclusion: Decodable {
	let groupID: String
	let variationID: String

	enum CodingKeys: String, CodingKey {
		case groupID = "group_id"
		case variationID = "variation_id"
	}
//
//	init(from decoder: Decoder) throws {
//		let values = try decoder.container(keyedBy: CodingKeys.self)
//		groupID = try values.decode(String.self, forKey: .groupID)
//		variationID = try values.decode(String.self, forKey: .variationID)
//	}
}

struct Variant: Decodable {
	let variantGroups: [VariantGroup]
	let exclusions: [Exclusion]

	enum CodingKeys: String, CodingKey {
		case variantGroups = "variant_groups"
		case exclusions = "exclude_list"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		exclusions = try values.decode([Exclusion].self, forKey: .exclusions)
		variantGroups = try values.decode([VariantGroup].self, forKey: .variantGroups)

		print(exclusions)
	}
}

struct APIResponse: Decodable {
	let variants: Variant

	enum CodingKeys: String, CodingKey {
		case variants
	}

//	init(from decoder: Decoder) throws {
//		let values = try decoder.container(keyedBy: CodingKeys.self)
//		variants = try values.decode(Variant.self, forKey: .variants)
//	}
}
