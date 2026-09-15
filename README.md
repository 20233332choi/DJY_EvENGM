# DJY_EvENGM

ESP32-S3를 CMSIS-DAP SWD 프로그래머로 사용해 FSK Energy Meter의 STM32F401RCT6 펌웨어를 기록하는 프로젝트입니다. EV 텔레메트리 기능을 이식하는 프로젝트가 아닙니다.

## 현재 상태

- ESP32-S3 실물 확인: 16 MB flash, 8 MB embedded PSRAM
- 공식 Espressif `esp-usb-bridge` v1.2.1을 SWD 모드로 빌드
- SWD 핀: `GPIO10 = SWCLK`, `GPIO8 = SWDIO`
- ESP32-S3 보드에 브리지 펌웨어 기록 및 해시 검증 완료
- FSK Energy Meter 공식 v1.8.2 release/debug 펌웨어 포함
- Energy Meter 실물 연결과 STM32 기록은 아직 수행하지 않음

## 사용 순서

1. [배선 문서](docs/WIRING.md)를 따라 Energy Meter를 연결합니다. 차량, HV, drive cable은 모두 분리합니다.
2. ESP32-S3의 **native USB/OTG 포트**를 PC에 연결합니다. COM8로 보였던 CP210x 포트는 ESP 자체 펌웨어 설치용입니다.
3. 연결만 시험합니다.

   ```powershell
   .\scripts\flash_energy_meter.ps1 -ProbeOnly
   ```

4. STM32F401 연결이 확인된 뒤 release 펌웨어를 기록합니다.

   ```powershell
   .\scripts\flash_energy_meter.ps1
   ```

ESP 브리지 펌웨어를 다시 설치하려면:

```powershell
.\scripts\install_bridge.ps1 -Port COM8
```

## 주요 파일

- `firmware/esp32-s3-swd-bridge/djy-evengm-swd-bridge.factory.bin`: ESP에 주소 `0x0`으로 쓰는 통합 이미지
- `firmware/fsk-energymeter-v1.8.2/fsk-energymeter-firmware/release/firmware-release.elf`: Energy Meter에 기록할 공식 release 이미지
- `firmware/esp-usb-bridge`: ESP 브리지 공식 소스와 DJY 빌드 설정
- `scripts/build_bridge.ps1`: 브리지 재빌드 및 산출물 패키징
- `scripts/install_bridge.ps1`: ESP 브리지 설치
- `scripts/flash_energy_meter.ps1`: 연결 시험 또는 Energy Meter 기록
- `gui/DJY_EvENGM-GUI.ps1`: 연결 확인·무결성 확인·release 전송 GUI

## GUI 실행

Windows PowerShell에서 다음을 실행하면 됩니다.

```powershell
.\gui\DJY_EvENGM-GUI.ps1
```

또는 프로젝트 폴더의 `run_gui.bat`을 더블클릭하면 됩니다.

`연결 확인`으로 먼저 CMSIS-DAP과 STM32를 확인한 뒤 `release 전송`을 클릭합니다. GUI는 USB 연결 즉시 자동 기록하지 않으며, 기록 버튼에 확인창을 표시합니다.

## 검증 경계

ESP 브리지의 빌드와 COM8 기록은 검증됐습니다. Energy Meter에 대한 SWD 연결, 실제 기록, 센서 영점 보정, 측정 정확도와 차량/HV 환경 동작은 실물 검증 전입니다.
