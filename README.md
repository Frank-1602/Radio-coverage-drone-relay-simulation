# Urban Radio Coverage Simulation with Dynamic UAV Relay Support

This project presents a MATLAB-based simulation of urban radio coverage for emergency communication scenarios, with a dynamic UAV/drone relay system used to improve radio link reliability in critical areas.

The case study is inspired by a real volunteering experience with the Italian Red Cross during the *Festa dei Santi Medici* in Bitonto, Italy. During this type of public event, emergency teams need to maintain reliable radio communication with a fixed medical coordination point while moving through different areas of the city.

The main idea of the project is to analyze and optimize the communication between two antennas:

- one antenna represents the Advanced Medical Post (PMA), acting as the fixed radio station;
- the other antenna represents a mobile emergency team moving on foot along the procession route.

When the direct communication link between these two antennas becomes weak or unreliable, a UAV/drone relay is introduced as a dynamic support node.

---

## Project Goal

The main goal of this project is to study the quality of the radio communication link between the PMA and a mobile emergency team in an urban environment.

The simulation evaluates the received signal power along a real procession route and identifies the areas where the direct radio link becomes insufficient.

When the received power drops below a predefined threshold, the system activates a UAV relay in order to improve the communication between the fixed medical post and the mobile team.

In summary, the project aims to:

- simulate radio propagation in a realistic urban scenario;
- evaluate the received signal strength between two antennas;
- identify coverage gaps along the route;
- introduce a UAV relay when the direct link is not reliable;
- compare the communication performance with and without drone support.

---

## Scenario

The idea for this project was born after a volunteering experience with the Italian Red Cross during the *Festa dei Santi Medici* in Bitonto, Italy.

During the event, several emergency teams operate in different areas of the city and need to stay in radio contact with the Advanced Medical Post. However, in an urban environment, the radio signal can be affected by buildings, distance, terrain irregularities and non-line-of-sight conditions.

To simplify the simulation, the scenario was modeled by considering a single mobile emergency team on foot following the entire procession route.

For this reason, the project models a realistic emergency communication scenario based on two main radio nodes:

- a fixed transmitter representing the PMA;
- a mobile receiver representing the emergency team on foot.

The mobile receiver follows the procession route, while the simulation computes the received signal power at each point. The purpose is to detect critical areas where the direct radio link between the two antennas becomes weak and to evaluate whether a UAV relay can dynamically restore or improve the communication.

The urban environment was modeled using OpenStreetMap data, while radio propagation was simulated in MATLAB using the Longley-Rice propagation model. environment was modeled using OpenStreetMap data, while radio propagation was simulated in MATLAB using the Longley-Rice propagation model.

---

## Methodology

The project was developed in MATLAB using radio propagation and antenna modeling tools.

The main simulation steps are:

1. Model the urban environment using OpenStreetMap data.
2. Define the fixed transmitter representing the PMA.
3. Define the mobile receiver representing the emergency team.
4. Discretize the procession route using geographic coordinates.
5. Compute the received signal strength along the route.
6. Detect critical points where the received power drops below -65 dBm.
7. Activate a UAV relay when the direct link is not sufficient.
8. Optimize the UAV antenna orientation using a directional Yagi-Uda antenna.
9. Compare the received power with and without UAV relay support.

---

## Radio Propagation Model

The simulation uses the Longley-Rice propagation model, also known as the Irregular Terrain Model.

This model provides a more realistic estimation of radio signal attenuation compared to ideal free-space propagation, since it can account for terrain irregularities and non-ideal propagation conditions.

In this project, Longley-Rice was used to estimate the received power between:

- the PMA and the mobile emergency team;
- the PMA and the UAV relay;
- the UAV relay and the mobile emergency team.

The operating frequency used in the simulation is:

```text
160 MHz
```

This frequency is representative of professional VHF radio communication systems.

---

## UAV Relay Strategy

The UAV is activated only when the received power of the direct link drops below the threshold of:

```text
-65 dBm
```

The drone acts as a mobile relay node and is equipped with:

- a receiving dipole antenna;
- a transmitting Yagi-Uda directional antenna;
- a dynamic positioning strategy;
- kinematic constraints based on the maximum movement allowed between consecutive simulation steps.

The drone does not remain active for the entire route. Instead, it is deployed only in critical areas and returns to its base once the direct radio link becomes reliable again.

This strategy reduces unnecessary drone usage and makes the relay system more efficient.

---

## Antenna Modeling

The communication between the PMA and the mobile emergency team is modeled using dipole antennas.

The UAV relay uses two antennas:

- a dipole antenna for receiving the signal;
- a directional Yagi-Uda antenna for transmitting toward the mobile team.

The Yagi-Uda antenna is used because it can concentrate the transmitted energy in a specific direction, improving the received power at the mobile receiver.

The drone antenna orientation is optimized during the simulation in order to maximize the received signal power.

---

## Results

The simulation showed that the direct radio link presents several critical areas along the route.

In the worst case, the received power without drone support reached approximately:

```text
-84.54 dBm
```

With the UAV relay active, the received power in the same critical region increased to approximately:

```text
-7.75 dBm
```

This corresponds to an improvement of about:

```text
76.79 dB
```

These results suggest that a UAV relay can significantly improve radio communication reliability in complex urban environments, especially when buildings, distance and terrain irregularities reduce the quality of the direct link.

---

## Key Features

- MATLAB-based radio propagation simulation
- Urban scenario modeled using OpenStreetMap data
- Longley-Rice propagation model
- Mobile receiver following a real route
- Received signal strength evaluation along the route
- Dynamic UAV relay activation
- Directional Yagi-Uda antenna modeling
- Antenna pointing optimization
- Drone repositioning with movement constraints
- Comparison between direct and UAV-assisted communication
- Export of simulation results for performance analysis

---

## Technologies Used

- MATLAB
- Antenna Toolbox
- RF propagation modeling
- Longley-Rice propagation model
- OpenStreetMap data
- Geographic coordinate processing
- UAV relay simulation

---


Francesco Danisi  
MSc Telecommunications Engineering  
Politecnico di Bari

---

## License

This project is released under the MIT License.
