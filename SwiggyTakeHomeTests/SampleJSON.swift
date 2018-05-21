//
//  SampleJSON.swift
//  SwiggyTakeHomeTests
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

let sampleJSONString =
"""
{
"variants": {
"variant_groups": [
{
"group_id": "1",
"name": "Crust",
"variations": [
{
"name": "Thin",
"price": 0,
"id": "1"
},
{
"name": "Thick",
"price": 0,
"id": "2"
},
{
"name": "Cheese burst",
"price": 100,
"id": "3"
}
]
},
{
"group_id": "2",
"name": "Size",
"variations": [
{
"name": "Small",
"price": 0,
"id": "10",
},
{
"name": "Medium",
"price": 100,
"id": "11"
},
{
"name": ":Large",
"price": 200,
"id": "12"
}
]
},
{
"group_id": "3",
"name": "Sauce",
"variations": [
{
"name": "Manchurian",
"price": 20,
"id": "20"
},
{
"name": "Tomato",
"price": 20,
"id": "21"
},
{
"name": "Mustard",
"price": 20,
"id": "22"
}
]
}
],
"exclude_list": [
[
{
"group_id": "1",
"variation_id": "3"
},
{
"group_id": "2",
"variation_id": "10"
}
],
[
{
"group_id": "2",
"variation_id": "10"
},
{
"group_id": "3",
"variation_id": "22"
}
]
]
}
}
"""
