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
	let `default`: Bool //is an Int on the API 🤷‍♀️
	let id: String
	let inStock: Bool //is an Int on the API 🤷‍♀️
	let isVeg: Bool?

	enum CodingKeys: String, CodingKey {
		case name
		case price
		case `default`
		case id
		case inStock
		case isVeg
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		price = try container.decode(Int.self, forKey: .price)
		let defaultInt = try container.decode(Int.self, forKey: .`default`)
		// could've been `default` = !(defaultInt == 0) but I prefer the clarity in this version
		`default` = defaultInt == 0 ? false : true
		id = try container.decode(String.self, forKey: .id)
		let inStockInt = try container.decode(Int.self, forKey: .inStock)
		inStock = inStockInt == 0 ? false : true
		// could've been inStock = inStockInt == 0 ? false : true but I prefer the clarity in this version
		// Also, Postel's law (https://en.wikipedia.org/wiki/Robustness_principle) states that you should "be conservative in what you do, be liberal in what you accept from others" so
		let isVegInt = try? container.decode(Int.self, forKey: .isVeg)
		isVeg = isVegInt.flatMap{ $0 == 0 }
	}

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

}

struct Exclusion: Decodable, Hashable {
	let groupID: String
	let variationID: String

	init(groupID: String, variationID: String) {
		self.groupID = groupID
		self.variationID = variationID
	}

	enum CodingKeys: String, CodingKey {
		case groupID = "group_id"
		case variationID = "variation_id"
	}
}

struct Variant: Decodable {
	let variantGroups: [VariantGroup]
	let exclusions: [[Exclusion]]

	enum CodingKeys: String, CodingKey {
		case variantGroups = "variant_groups"
		case exclusions = "exclude_list"
	}
}

struct APIResponse: Decodable {
	let variants: Variant

	enum CodingKeys: String, CodingKey {
		case variants
	}
}
