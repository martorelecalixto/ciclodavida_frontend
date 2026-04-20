import '../constants.dart';
import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String? svgSrc, title, totalStorage;
  ////final int? numOfFiles, percentage;
  final Color? color;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.totalStorage,
    ////this.numOfFiles,
    ///this.percentage,
    this.color,
  });
}

List demoMyFiles = [
  CloudStorageInfo(
    title: "Aereo",
    ////numOfFiles: 1328,
    svgSrc: "assets/icons/ticket.svg",
    totalStorage: "1.9GB",
    color: primaryColor,
    //percentage: 35,
  ),
  CloudStorageInfo(
    title: "Serviços",
    ////numOfFiles: 1328,
    svgSrc: "assets/icons/briefcase.svg",
    totalStorage: "2.9GB",
    color: Color(0xFFFFA113),
    ////percentage: 35,
  ),
  CloudStorageInfo(
    title: "Receber",
    ////numOfFiles: 1328,
    svgSrc: "assets/icons/plus.svg",
    totalStorage: "1GB",
    color: Color(0xFFA4CDFF),
   //// percentage: 10,
  ),
  CloudStorageInfo(
    title: "Pagar",
    ////numOfFiles: 5328,
    svgSrc: "assets/icons/minus.svg",
    totalStorage: "7.3GB",
    color: Color(0xFF007EE5),
    ////percentage: 78,
  ),
];
