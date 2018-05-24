//
//  ValidExclusions.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 23/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

// We're making this as general as possible
//TODO: mention the README about wrapping Stringly typed IDs in something like: https://medium.com/compileswift/avoiding-primitive-obsession-in-swift-5325b65d521e
func validExclusions(groupID: String, exclusionLists: [Set<Exclusion>], selectedIDs: [String], variantGroups: [VariantGroup]) -> [String: Set<Exclusion>] {

	let selectedPairs = zip(selectedIDs, variantGroups).map{ Exclusion(groupID: $0.1.groupID, variationID: $0.0) }

	let exclusionListsWeCareAbout = exclusionLists.filter{ !$0.intersection(selectedPairs).isEmpty }

	let disabledElementsInVariantGroup = exclusionListsWeCareAbout.map { (set) -> ([String], Set<Exclusion>) in
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

func previousOptions(forExclusionReasons exclusionReasons: Set<Exclusion>, variantGroups: [VariantGroup]) -> [Variation] {
	return exclusionReasons.compactMap { exclusion in
		guard let variantGroup = variantGroups.first(where: { $0.groupID == exclusion.groupID }) else {
			return nil
		}
		guard let variation = variantGroup.variations.first(where: { $0.id == exclusion.variationID }) else {
			return nil
		}
		return variation
	}
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
