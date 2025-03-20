# QBCore Trucker Job

This is a trucking resource for FiveM built for QBCore. It allows players to take on trucking jobs, delivering various types of cargo to different locations. The script includes features such as timed job generation, skill levels, and penalties for late or damaged deliveries.

## Features

- Random job generation with different skill levels and cargo types.
- Timed and fragile job types with XP multipliers.
- Penalties for late deliveries and damaged cargo.
- Truck return system.
- Configurable job settings.

## Installation

1. Clone the repository or download the script files.
2. Place the script in your `resources` folder.

## Configuration

The script can be configured through the `config.lua` file. Below are some of the key configuration options:

- `FuelResource`: The fuel resource to use.
- `JobGenerationTimer`: How often a job is generated in minutes.
- `MaxJobs`: Maximum number of jobs that can be generated.
- `FragileChanceGenerator`: Chance for a fragile job to be generated.
- `TimedChanceGenerator`: Chance for a timed job to be generated.
- `XPReward`: XP reward for completing a job.
- `Multipliers`: XP multipliers for fragile and timed jobs.
- `PayPerMeter`: Payment per meter traveled.
- `LateDeliveryPenalty`: Penalty percentage for late deliveries.
- `DamagePenaltyThreshold`: Health threshold for damage penalties.
- `DamagePenalty`: Penalty percentage for damaged cargo.
- `DefaultTruck`: Default truck for players to use.
- `Trucks`: List of available trucks and their prices.
- `DeliveryTypes`: Different types of deliveries based on skill levels.

## License

QBCore Framework
Copyright (C) 2021 Joshua Eger

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>