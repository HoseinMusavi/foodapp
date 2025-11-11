import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart'; // ایمپورت flutter_map
import 'package:latlong2/latlong.dart'; // پکیج کمکی برای LatLng در flutter_map

// این ایمپورت را اضافه کنید تا بتوانید نوع LatLng مورد انتظار را برگردانید
// اگر از LatLng سفارشی خودتان استفاده می‌کنید، آن را ایمپورت کنید
import 'package:customer_app/core/utils/lat_lng.dart' as core_lat_lng; // <-- فرض کردیم LatLng شما اینجا است

class MapAddressSelectionPage extends StatefulWidget {
  const MapAddressSelectionPage({super.key});

  @override
  State<MapAddressSelectionPage> createState() =>
      _MapAddressSelectionPageState();
}

class _MapAddressSelectionPageState extends State<MapAddressSelectionPage> {
  // مختصات پیش فرض (مرکز شهر بهبهان)
  static final LatLng _defaultLocation = LatLng(30.5970, 50.2407);

  LatLng _currentMapCenter = _defaultLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// دریافت موقعیت فعلی کاربر برای مرکز نقشه
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('سرویس موقعیت مکانی غیرفعال است. لطفا فعال کنید.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسترسی به موقعیت مکانی رد شد.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('دسترسی به موقعیت مکانی برای همیشه رد شده است. از تنظیمات فعال کنید.')));
      return;
    }


    try {
      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      // از mounted استفاده کنید تا اگر ویجت از بین رفته بود، setState اجرا نشود
      if (mounted) {
        setState(() {
          _currentMapCenter = userLocation;
        });
        _mapController.move(_currentMapCenter, 16.0); // زوم اولیه 16
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('خطا در دریافت موقعیت: $e')));
       }
    }
  }

  // وقتی دوربین حرکت میکند، مرکز نقشه را آپدیت کن
  void _onPositionChanged(MapPosition position, bool hasGesture) {
     if (position.center != null) {
        _currentMapCenter = position.center!;
     }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب موقعیت مکانی'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentMapCenter,
              initialZoom: 16.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // **** نام پکیج خودتان را اینجا قرار دهید ****
                // میتوانید از android/app/build.gradle.kts مقدار applicationId را بخوانید
                userAgentPackageName: 'com.example.test_app', // <-- اینجا را با نام پکیج خودتان عوض کنید
              ),
            ],
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('تایید این موقعیت',
                  style: TextStyle(fontSize: 16)),
              onPressed: () {
                print("Selected Location (latlong2): ${_currentMapCenter.latitude}, ${_currentMapCenter.longitude}");

                // **** تبدیل نوع داده برای سازگاری ****
                // LatLngِ latlong2 را به LatLng سفارشی خودتان تبدیل میکنیم
                 final coreLatLng = core_lat_lng.LatLng( // <-- استفاده از نوع سفارشی
                   latitude: _currentMapCenter.latitude,
                   longitude: _currentMapCenter.longitude
                 );
                 Navigator.pop(context, coreLatLng); // <-- برگرداندن نوع سفارشی
              },
            ),
          ),
        ],
      ),
    );
  }
}