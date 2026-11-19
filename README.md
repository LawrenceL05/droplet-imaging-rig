# Droplet imaging rig

Capture side-view images of sessile droplets at a fixed working distance. A Windows laptop sends a capture command over SSH to a Raspberry Pi Zero 2 W. The Pi saves a JPEG and the laptop retrieves it over SCP.

## Hardware and verification status

The controller kit label identifies a Raspberry Pi Zero 2 W. The camera PCB reads Arducam UC-517 Rev.F and the package reads B024002. These markings match the B0240 family with a Sony IMX477 sensor and a 6 mm manual-focus CS-mount lens. Live sensor identification and the first reference image are pending.

## Connect and check the camera

1. With power disconnected, seat the Pi Zero-compatible CSI ribbon in the Pi and camera connectors. Check contact orientation at both latches. The camera-side connector for B0240 is 22-pin, top-contact.
2. Boot Raspberry Pi OS with the rpicam apps installed. Enable SSH and connect the Pi and the Windows laptop to a network that allows them to reach each other. Use the username and hostname or IP configured on the Pi.
3. In a Pi terminal, run the commands below. Check for Raspberry Pi Zero 2 W and a camera entry containing imx477 before proceeding.

```bash
cat /proc/device-tree/model; echo
rpicam-hello --list-cameras
```

## Set up the shot

Mount the camera side-on with its optical axis level with the substrate. Place a ruler or calibration target in the droplet plane. Remove the lens cap and position a diffuse backlight behind the target. Use the command below for a reference shot. Inspect the substrate edge and scale at full resolution, adjust focus and repeat. Lock the lens rings and mark the sample position once both are sharp. Record the working distance and keep the mount and backlight fixed.

## Trigger a capture from Windows

Open PowerShell in the repository folder. The script uses the OpenSSH client commands ssh and scp. Replace YOUR_USER@PI_HOST with the Pi login. For a first SSH connection, check the host fingerprint against the Pi before accepting it.

```powershell
.\src\capture_droplet.ps1 -Pi YOUR_USER@PI_HOST -Sample calibration
.\src\capture_droplet.ps1 -Pi YOUR_USER@PI_HOST -Sample A1
```

Every command takes one photo. The Pi keeps the original under ~/droplet-captures/. The laptop copy goes into data/captures/ and the script prints its path. Each filename includes the sample ID, laptop timestamp and a unique suffix. Use -OutputDir to choose another destination. If transfer fails after capture, retrieve the original from the Pi.

Before a collection session, open the calibration image and repeat the shot without moving the target. Check scale, focus, baseline position and brightness across both images. The capture script uses automatic exposure.

## Hardware references

- [Arducam IMX477 connector and lens options](https://docs.arducam.com/Raspberry-Pi-Camera/Native-camera/12MP-IMX477/)
- [Arducam B0240 kit details](https://www.arducam.com/b0240-arducam-imx477-hq-quality-camera.html)
- [Raspberry Pi camera software](https://www.raspberrypi.com/documentation/accessories/camera-software.html)
