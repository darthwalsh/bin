I wasn't very familiar with specs of Arduino vs Pi Pico, so here's #ai-slop summary from ChatGPT

## Taxonomy of Embedded Systems Hardware
- **Microcontrollers (MCUs)** – single-chip processors with integrated memory/peripherals, usually no OS
    - **8-bit MCUs** → very simple, low power, tight loops
        - ATmega328 (Arduino Uno), ATtiny
    - **32-bit Basic MCUs** → faster cores, more RAM, real-time control
        - STM32, ARM Cortex-M4, Teensy, Arduino Due
    - **IoT MCUs** → add wireless + higher-level runtimes (MicroPython, FreeRTOS)
        - ESP32, ESP8266, nRF52840
- **Crossover MCUs / High-end Controllers** – blur MCU ↔ SBC line, more capable but still microcontroller-like
    - Raspberry Pi Pico (RP2040), ESP32-S3, NXP i.MX RT
- **Single-Board Computers (SBCs)** – full general-purpose computers that run Linux or similar
    - Raspberry Pi family, BeagleBone Black, Odroid, LattePanda, UP Board
- **Edge AI / Accelerator Boards** – embedded modules with GPU/NPU/TPU for ML workloads
    - NVIDIA Jetson, Google Coral TPU, Intel Neural Compute Stick

## Capability

| **Class**                         | **RAM** | **Freq (MHz)**    | **Watts** | **Avg. Price (USD)** | **Abilities Summary**                                                      |
| --------------------------------- | ------- | ----------------- | --------- | -------------------- | -------------------------------------------------------------------------- |
| **8-bit MCUs**                    | 2 KB    | 16                | 0.05      | $5–$20               | Very simple, single program loop; GPIO, timing, sensors.                   |
| **32-bit Basic MCUs**             | 128 KB  | 120               | 0.2       | $10–$30              | Faster math, real-time control, C/C++ development.                         |
| **IoT MCUs**                      | 520 KB  | 240               | 1         | $5–$15               | Wi-Fi/Bluetooth, MicroPython/Arduino IDE, multitasking.                    |
| **Crossover MCUs**                | 264 KB  | 133               | 1.5       | $4–$12               | Bridges MCU ↔ SBC; dual cores, USB, light ML, networking.                  |
| **Single-Board Computers (SBCs)** | 4 GB    | 1,500             | 7         | $35–$150             | Full Linux OS, multitasking, closer to laptop; GUIs, servers, moderate ML. |
| **Edge AI Modules**               | 8 GB    | 1,200<br>+GPU/NPU | 15        | $100–$400            | Run ML (STT, vision) real-time, hardware acceleration, Linux.              |

