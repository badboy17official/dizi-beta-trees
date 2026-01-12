# Dizi GPIO and Hardware Configuration Extract

## Source DTS Analysis
Extracted from: `01_dtbdump_Qualcomm_Technologies,_Inc._Parrot_QRD,_DIZI_based_on_SM7435P.dts`

---

## Hall Sensor (Lid Detection)

**Location:** Lines 1951-1971

```dts
qcom,hall-in-lid {
    qcom,entry-name = "mi_hall_lid";
    interrupt-controller;
    #interrupt-cells = <0x02>;
    phandle = <0x26>;
};

xiaomi_hall {
    compatible = "xiaomi-hall";
    status = "ok";
    
    lid_hall {
        label = "lid_hall";
        hall_pin = <0xffffffff 0x41 0x01>;  // GPIO 65 (0x41)
        linux,input-type = <0x05>;           // EV_SW (switch event)
        linux,code = <0x00>;                 // SW_LID
        interrupts-extended = <0x26 0x00 0x00 0x26 0x01 0x00>;
        interrupt-names = "open_irq", "close_irq";
    };
};
```

**Configuration:**
- GPIO: 65 (0x41)
- Input Type: EV_SW (0x05)
- Event Code: SW_LID (0x00)
- Dual interrupts: open_irq, close_irq

---

## FM Radio (RTC6226)

**Location:** Lines 129-138

```dts
rtc6226 {
    compatible = "rtc6226";
    reg = <0x64>;                            // I2C address: 0x64
    fmint-gpio = <0xffffffff 0x69 0x00>;    // GPIO 105 (0x69)
    vdd-supply = <0xffffffff>;
    rtc6226,vdd-supply-voltage = <0x2ab980 0x2ab980>;  // 2.8V (2,800,000 uV)
    rtc6226,vdd-load = <0x3a98>;            // 15000 uA
    vio-supply = <0xffffffff>;
    rtc6226,vio-supply-voltage = <0x1b7740 0x1b7740>;  // 1.8V (1,800,000 uV)
};
```

**Configuration:**
- I2C Address: 0x64
- Interrupt GPIO: 105 (0x69)
- VDD: 2.8V @ 15mA
- VIO: 1.8V

---

## Volume Keys

**Location:** Lines 434-444 (PMK8350 pinctrl), Lines 1973-1988 (gpio_keys)

```dts
/* PMK8350 Volume Up Key */
key_vol_up_default {
    pins = "gpio1";
    function = "normal";
    input-enable;
    bias-pull-up;
    power-source = <0x00>;
    phandle = <0x27>;
};

/* GPIO Keys Node */
gpio_keys {
    compatible = "gpio-keys";
    label = "gpio-keys";
    pinctrl-names = "default";
    pinctrl-0 = <0x27>;
    
    vol_up {
        label = "volume_up";
        gpios = <0x28 0x01 0x01>;           // PMK8350 GPIO1
        linux,input-type = <0x01>;          // EV_KEY
        linux,code = <0x73>;                // KEY_VOLUMEUP (115)
        gpio-key,wakeup;
        debounce-interval = <0x0f>;         // 15ms
        linux,can-disable;
    };
};
```

**Configuration:**
- Volume Up: PMK8350 GPIO1
- Key Code: KEY_VOLUMEUP (115 / 0x73)
- Debounce: 15ms
- Wake source: Yes

---

## Camera Sensors

### Rear Camera (cam-sensor0)

**Location:** Lines 8036-8062

```dts
qcom,cam-sensor0 {
    cell-index = <0x00>;
    compatible = "qcom,cam-sensor";
    csiphy-sd-index = <0x00>;
    sensor-position-roll = <0x5a>;          // 90 degrees
    sensor-position-pitch = <0x00>;         // 0 degrees
    sensor-position-yaw = <0xb4>;           // 180 degrees
    
    /* Clocks */
    clock-names = "cam_clk";
    clocks = <camcc 0x30>;                  // MCLK0
    
    /* CCI Configuration */
    cci-device = <0>;
    cci-master = <0x00>;
    
    /* GPIOs */
    gpios = <tlmm 0x27 0x00                 // GPIO 39 (MCLK0)
             tlmm 0x2c 0x00>;               // GPIO 44 (RESET)
    gpio-no-mux = <0x00>;
    gpio-req-tbl-num = <0 1>;
    gpio-req-tbl-flags = <1 0>;
    gpio-req-tbl-label = "CAMIF_MCLK0", "CAM_RESET0";
    
    /* Power Supplies */
    regulator-names = "cam_vio", "cam_vana", "cam_vdig", "cam_clk";
    cam_clk-supply = <&cam_cc_camss_top_gdsc>;
    cam_vdig-supply = <&L15B>;              // PM7325B LDO15
    cam_vana-supply = <&L28B>;              // PM7325B LDO28
    cam_vio-supply = <&L1E>;                // PM8010E LDO1
};
```

**Configuration:**
- Sensor: GC08A3 (rear, 8MP)
- MCLK: GPIO 39
- Reset: GPIO 44
- CCI Master: 0
- CSI PHY: 0
- Orientation: 90° roll, 180° yaw
- Power:
  - VDIG: L15B (PM7325B LDO15)
  - VANA: L28B (PM7325B LDO28)
  - VIO: L1E (PM8010E LDO1)

### Front Camera (cam-sensor1)

**Location:** Lines 8072-8097

```dts
qcom,cam-sensor1 {
    cell-index = <0x01>;
    compatible = "qcom,cam-sensor";
    csiphy-sd-index = <0x02>;
    sensor-position-roll = <0x10e>;         // 270 degrees
    sensor-position-pitch = <0x00>;         // 0 degrees
    sensor-position-yaw = <0x00>;           // 0 degrees
    
    /* Clocks */
    clock-names = "cam_clk";
    clocks = <camcc 0x32>;                  // MCLK2
    
    /* CCI Configuration */
    cci-device = <0>;
    cci-master = <0x01>;
    
    /* GPIOs */
    gpios = <tlmm 0x28 0x00                 // GPIO 40 (MCLK2)
             tlmm 0x2d 0x00>;               // GPIO 45 (RESET)
    gpio-no-mux = <0x00>;
    gpio-req-tbl-num = <0 1>;
    gpio-req-tbl-flags = <1 0>;
    gpio-req-tbl-label = "CAMIF_MCLK2", "CAM_RESET1";
    
    /* Power Supplies */
    regulator-names = "cam_vio", "cam_vana", "cam_vdig", "cam_clk";
    cam_clk-supply = <&cam_cc_camss_top_gdsc>;
    cam_vdig-supply = <&L15B>;              // PM7325B LDO15
    cam_vana-supply = <&L28B>;              // PM7325B LDO28
    cam_vio-supply = <&L1E>;                // PM8010E LDO1
};
```

**Configuration:**
- Sensor: OV08D10 (front, 8MP)
- MCLK: GPIO 40
- Reset: GPIO 45
- CCI Master: 1
- CSI PHY: 2
- Orientation: 270° roll
- Power: Same as rear camera

---

## Bluetooth/WiFi (WCN6750)

**From earlier DTS analysis:**

```dts
bt_wcn6750 {
    compatible = "qcom,wcn6750-bt";
    qcom,bt-reset-gpio = <tlmm GPIO_NUM>;
    qcom,bt-sw-ctrl-gpio = <tlmm GPIO_NUM>;
    qcom,wl-reset-gpio = <tlmm GPIO_NUM>;
    
    /* Power supplies */
    qcom,bt-vdd-io-supply = <&L22B>;        // PM7325B LDO22
    qcom,bt-vdd-aon-supply = <&S7B>;        // PM7325B SMPS7
    qcom,bt-vdd-dig-supply = <&S7B>;
    qcom,bt-vdd-rfacmn-supply = <&S7B>;
    qcom,bt-vdd-rfa-0p8-supply = <&S7B>;
    qcom,bt-vdd-rfa1-supply = <&S8E>;       // PM8010E SMPS8
    qcom,bt-vdd-rfa2-supply = <&S8B>;       // PM7325B SMPS8
    qcom,bt-vdd-ipa-2p2-supply = <&S9B>;    // PM7325B SMPS9
};

qcom,wcn6750 {
    compatible = "qcom,cnss-qca6750";
    vdd-cx-mx-supply = <&S7B>;
    vdd-1.8-xo-supply = <&S8E>;
    vdd-1.3-rfa-supply = <&S8B>;
};
```

---

## Display Panel

**Location:** Lines 82-83 (n83_35_02_0a and n83_42_02_0b panels)

```dts
qcom,mdss_dsi_n83_35_02_0a_wqxga_video_cphy {
    mi,esd-err-irq-gpio = <tlmm GPIO_NUM>;
    mi,esd-err-irq-gpio-second = <tlmm GPIO_NUM>;
    qcom,platform-reset-gpio = <tlmm GPIO_NUM>;
    qcom,platform-bklight-en-gpio = <tlmm GPIO_NUM>;
    qcom,platform-te-gpio = <tlmm GPIO_NUM>;
};
```

---

## Touch Panel

**Location:** Line 92

```dts
touch@0 {
    interrupt-parent = <tlmm>;
    novatek,irq-gpio = <tlmm GPIO_NUM>;
};
```

---

## Audio Amplifiers

**Location:** Lines 47-49

```dts
/* Stereo speakers - two amplifier chips */
si_pa_L_ONE {
    si,si_pa_reset = <tlmm GPIO_NUM>;
};

si_pa_L_TWO {
    si,si_pa_reset = <tlmm GPIO_NUM>;
};

si_pa_R_ONE {
    si,si_pa_reset = <tlmm GPIO_NUM>;
};

si_pa_R_TWO {
    si,si_pa_reset = <tlmm GPIO_NUM>;
};
```

---

## Power Management

### PM7325B (Primary PMIC)
- **S7B (SMPS7):** WiFi/BT core power (CX/MX)
- **S8B (SMPS8):** WiFi/BT RF 1.3V
- **S9B (SMPS9):** BT IPA 2.2V
- **L15B (LDO15):** Camera VDIG
- **L22B (LDO22):** WiFi/BT VDD-IO
- **L24B (LDO24):** eMMC VDD
- **L28B (LDO28):** Camera VANA

### PM8010E (Secondary PMIC)
- **S8E (SMPS8):** WiFi/BT XO 1.8V
- **L1E (LDO1):** Camera VIO

### PM8010I/J (Tertiary PMICs)
- **BOB:** Codec and audio power

### PMK8350 (Power Management)
- **GPIO1:** Volume Up key

---

## Summary Table

| Component | GPIO/Pin | Function | Notes |
|-----------|----------|----------|-------|
| Hall Sensor | GPIO 65 | Lid detection | Dual interrupts (open/close) |
| FM Radio INT | GPIO 105 | FM interrupt | I2C addr: 0x64 |
| Volume Up | PMK8350 GPIO1 | Volume up key | Wake source |
| Rear Cam MCLK | GPIO 39 | Camera clock | GC08A3 |
| Rear Cam RST | GPIO 44 | Camera reset | GC08A3 |
| Front Cam MCLK | GPIO 40 | Camera clock | OV08D10 |
| Front Cam RST | GPIO 45 | Camera reset | OV08D10 |

---

## Device Tree Files to Create

Based on this analysis, we need to create:

1. **dizi-sm7435.dtsi** - Main device overlay
2. **dizi-pinctrl.dtsi** - GPIO pin configurations
3. **camera/dizi-camera-sensor-qrd.dtsi** - Camera configuration
4. **display/dizi-sde-display-qrd.dtsi** - Display configuration
5. **audio/dizi-audio-qrd.dtsi** - Audio/speaker configuration

## Next Steps

1. Create kernel device tree files using this GPIO mapping
2. Verify voltage rails match stock firmware
3. Test camera sensor probing with extracted GPIOs
4. Validate FM Radio I2C communication
5. Test hall sensor lid detection events
