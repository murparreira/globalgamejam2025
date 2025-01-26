extends Node

var data = {
	'current_level': 'level_1',
	'current_minigame_city': null,
	'current_minigame_tube': null,
	'current_oxygen': 100,
	'current_player_position': null,
	'levels': {
		'level_1': {
			'cities': {
				'city_1': {
					'node': null,
					'completed': false
				}
			},
			'tube': false
		},
		'level_2': {
			'cities': {
				'city_1': {
					'node': null,
					'completed': false
				},
				'city_2': {
					'node': null,
					'completed': false
				},
				'city_3': {
					'node': null,
					'completed': false
				}
			},
			'tube': false
		},
		'level_3': {
			'cities': {
				'city_1': {
					'node': null,
					'completed': false
				},
				'city_2': {
					'node': null,
					'completed': false
				},
				'city_3': {
					'node': null,
					'completed': false
				},
				'city_4': {
					'node': null,
					'completed': false
				},
				'city_5': {
					'node': null,
					'completed': false
				}
			},
			'tube': false
		}
	}
}

func set_defaults() -> void:
	data['current_level'] = 'level_1'
	data['current_minigame_city'] = null
	data['current_oxygen'] = 100
	data['current_player_position'] = null
