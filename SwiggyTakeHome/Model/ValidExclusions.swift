//
//  ValidExclusions.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 23/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

// We're making this as general as possible
// the `Exclusion` type is the perfect representation of a user's choice 🤯
func validExclusions(groupID: String, exclusionLists: [Set<Exclusion>], selectedIDs: [String], variantGroups: [VariantGroup]) -> [String: Set<Exclusion>] {
	// Exclusion is a perfect representation of a user's choice
	let selectedPairs = zip(selectedIDs, variantGroups).map{ Exclusion(groupID: $0.1.groupID, variationID: $0.0) }

	let elligibleExclusionLists = exclusionLists.filter { !$0.intersection(selectedPairs).isEmpty }

	let disabledElementsInVariantGroup = elligibleExclusionLists.map { (set) -> ([String], Set<Exclusion>) in
		let disabledElements = set.filter {
				$0.groupID == groupID
			}.map {
				$0.variationID
			}

		let reasonsForDisabledElements =  set.filter { (exclusion) -> Bool in
			selectedPairs.filter{ $0.groupID == exclusion.groupID }.count > 0
		}
		return (disabledElements, reasonsForDisabledElements)
	}

	let reasonDict: [String: Set<Exclusion>] = disabledElementsInVariantGroup.reduce([:]) { (dict, arg1) in
		let (disabledIDs, reasons) = arg1
		var copy = dict
		for disabledID in disabledIDs {
			if let set = copy[disabledID] {
				copy[disabledID] = set.union(reasons)
			} else {
				copy[disabledID] = reasons
			}
		}
		return copy
	}

	return reasonDict
}

func itemNames(for exclusions: Set<Exclusion>, variantGroups: [VariantGroup]) -> [String] {
	return exclusions.compactMap { (exclusion) in
		guard let variant = variantGroups.first(where: { (variantGroup) in
			variantGroup.groupID == exclusion.groupID
		}) else {
			return nil
		}
		guard let variation = variant.variations.first(where: { (variation) in
			variation.id == exclusion.variationID
		}) else {
			return nil
		}
		return variation.name
	}
}
