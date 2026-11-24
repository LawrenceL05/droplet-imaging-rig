# Droplet imaging rig

Capture side-view images of sessile droplets at a fixed working distance. A Windows laptop sends a capture command over SSH to a Raspberry Pi Zero 2 W. The Pi saves a JPEG and the laptop retrieves it over SCP.

## Hardware and verification status

The controller kit label identifies a Raspberry Pi Zero 2 W. The camera PCB reads Arducam UC-517 Rev.F and the package reads B024002. These markings match the B0240 family with a Sony IMX477 sensor and a 6 mm manual-focus CS-mount lens. The Pi identified the sensor as `imx477` and captured multiple 4056 × 3040 JPEGs. The laptop retrieved those files over USB. Scale and focus still need a calibration image.

## Connect the rig over USB

1. With power disconnected, seat the CSI ribbon in both connectors and close both latches. The B0240 camera uses a 22-pin, top-contact connector.
2. For a new card, configure Raspberry Pi OS Lite (32-bit) with the hostname `dropletpi`, a user account, key-based SSH and USB gadget mode. The tested rig uses the account `lawrence`. Keep the private key on the laptop.
3. Connect a data-capable cable from the laptop to the Pi port marked **USB**, next to mini-HDMI. The **PWR IN** port supplies power only.
4. On Windows, check for **Raspberry Pi USB Remote NDIS Network Device** under Network adapters. If Windows shows a COM port instead, install the signed Raspberry Pi USB gadget driver. [Official USB setup guide](https://www.raspberrypi.com/news/usb-gadget-mode-in-raspberry-pi-os-ssh-over-usb/)
5. Add this host entry to the laptop's OpenSSH config (`~/.ssh/config`). Adjust the identity path and username if your setup differs. Both SSH and SCP use this entry.

```sshconfig
Host dropletpi.local
    User lawrence
    IdentityFile ~/.ssh/dropletpi_ed25519
    IdentitiesOnly yes
```

From PowerShell, check the board and sensor. On first connection, verify the host fingerprint against the Pi before accepting it.

```powershell
ssh lawrence@dropletpi.local "cat /proc/device-tree/model && echo && rpicam-hello --list-cameras"
```

Look for `Raspberry Pi Zero 2 W` and `imx477 [4056x3040`. If SSH reports `Connection refused` on a fresh installation, shut down the Pi and insert the card into the laptop. Create an empty file named `ssh` in the root of the `bootfs` partition. Eject the card, return it to the Pi and boot again.

If the camera list is empty, power down before checking the ribbon. On this rig, the working boot configuration in `/boot/firmware/config.txt` uses `camera_auto_detect=0` and `dtoverlay=imx477` in sections that apply to the Zero 2 W. Preserve the USB overlay. Reboot after editing the file, then repeat the sensor check.

## Set up the shot

Mount the camera side-on with its optical axis level with the substrate. Place a ruler or calibration target in the droplet plane. Remove the lens cap and position a diffuse backlight behind the target. Use the command below for a reference shot. Inspect the substrate edge and scale at full resolution, adjust focus and repeat. Lock the lens rings and mark the sample position once both are sharp. Record the working distance and keep the mount and backlight fixed.

## Trigger a capture from Windows

Open PowerShell in the repository folder. Use the first command for the reference image. Use the second for a sample and replace `A1` with its identifier.

```powershell
.\src\capture_droplet.ps1 -Pi lawrence@dropletpi.local -Sample calibration
.\src\capture_droplet.ps1 -Pi lawrence@dropletpi.local -Sample A1
```

Every command takes one photo. The Pi keeps the original under ~/droplet-captures/. The laptop copy goes into data/captures/ and the script prints its path. Each filename includes the sample ID, laptop timestamp and a unique suffix. To save directly to the Windows Pictures folder, add `-OutputDir ([Environment]::GetFolderPath('MyPictures'))` to the command. If transfer fails after capture, retrieve the original from the Pi.

Before a collection session, open the calibration image and repeat the shot without moving the target. Check scale, focus, baseline position and brightness across both images. The capture script uses automatic exposure.

## Hardware references

- [Arducam IMX477 connector and lens options](https://docs.arducam.com/Raspberry-Pi-Camera/Native-camera/12MP-IMX477/)
- [Arducam B0240 kit details](https://www.arducam.com/b0240-arducam-imx477-hq-quality-camera.html)
- [Raspberry Pi camera software](https://www.raspberrypi.com/documentation/accessories/camera-software.html)
