[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
<!--
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>
-->
  <h3 align="center">Crestron Scripts</h3>

  <p align="center">
    A colleciton of Powershell Scripts for Setup of Crestron Hardware

  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#prerequisites">Prerequisites</a></li>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#Scripts">Scripts</a>
        <ul><a href="#nvx-firmware">NVX Firmware</a></ul>
        <ul><a href="#discover-to-csv">Discover to CVS</a></ul>
        <ul><a href="#write-info-from-csv">Write Info from CSV</a></ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

No one likes manually creating documentation. Typing Mac address and serial numbers. Creating IP address lists. Manually assigning them to devices. Then Uploading firmware to sometimes hundreds of devies. Not fun at all. This is a collection of scripts I have written for use on my projects. Posting them here for me to keep up with them as well as share with others. 


## Prerequisites

These Scripts are to be used by Authorized Crestron users only and they require installation of Crestron software including toolbox and the Crestron EDK for Powershell. These scripts were tested on Powershell version 5.1.19041.906


## Scripts

### NVX Firmware

### Discover to CSV

Simply runs discovery on your network and outputs the relative info to a CSV file in your Documents folder with a date/Time stamp in the file name. Allows for copy/paste or modification to create useful documentation. 

### Write Info From CSV
Reads info from a CSV file. Opens a connection to device at CurrentIP and sets the new IPAddress, IPMask, DefRouter, and IP Table, Disables DHCP and then reboots the device. This is used in conjunction with Discover to CSV

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact


Project Link: [https://github.com/intellectualrockstar/CrestronScripts](https://github.com/intellectualrockstar/CrestronScripts)



<!-- ACKNOWLEDGEMENTS -->
<!-- ## Acknowledgements -->





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/intellectualrockstar/CrestronScripts.svg?style=for-the-badge
[contributors-url]: https://github.com/intellectualrockstar/CrestronScripts/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/intellectualrockstar/CrestronScripts.svg?style=for-the-badge
[forks-url]: https://github.com/intellectualrockstar/CrestronScripts/network/members
[stars-shield]: https://img.shields.io/github/stars/intellectualrockstar/CrestronScripts.svg?style=for-the-badge
[stars-url]: https://github.com/intellectualrockstar/CrestronScripts/stargazers
[issues-shield]: https://img.shields.io/github/issues/intellectualrockstar/CrestronScripts.svg?style=for-the-badge
[issues-url]: https://github.com/intellectualrockstar/CrestronScripts/issues
[license-shield]: https://img.shields.io/github/license/intellectualrockstar/CrestronScripts.svg?style=for-the-badge
[license-url]: https://github.com/intellectualrockstar/CrestronScripts/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/johnson2studios
[product-screenshot]: images/screenshot.png
