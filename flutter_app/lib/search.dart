import 'package:flutter_app/dr_details.dart';
import 'package:flutter_app/home_user.dart';
import 'package:flutter_app/medical_record.dart';
import 'package:flutter_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 20.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const String baseUrl = 'http://10.0.2.2:8080/api/patient';
}

class AppColors {
  static const Color primary = Colors.blue;
  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color cardBackground = Colors.white;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

enum City {
  ALL,
  CAIRO,
  GIZA,
  ALEXANDRIA,
  LUXOR,
  ASWAN,
  PORT_SAID,
  SUEZ,
  ISMAILIA,
  FAIYUM,
  DAMIETTA,
  ASYUT,
  MINYA,
  BENI_SUEF,
  SHARQIA,
  DAKAHLIYA,
  GHARBIA,
  MONUFIA,
  KAFR_EL_SHEIKH,
  BEHEIRA,
  QENA,
  SOHAG,
  RED_SEA,
  MATROUH,
  NEW_VALLEY,
  NORTH_SINAI,
  SOUTH_SINAI,
}

enum DoctorSpeciality {
  ALL,
  CARDIOLOGY,
  DERMATOLOGY,
  NEUROLOGY,
  ORTHOPEDICS,
  OPHTHALMOLOGY,
  OTOLARYNGOLOGY,
}

extension CityExtension on City {
  String get displayName {
    switch (this) {
      case City.ALL:
        return 'All';
      case City.CAIRO:
        return 'Cairo';
      case City.GIZA:
        return 'Giza';
      case City.ALEXANDRIA:
        return 'Alexandria';
      case City.LUXOR:
        return 'Luxor';
      case City.ASWAN:
        return 'Aswan';
      case City.PORT_SAID:
        return 'Port Said';
      case City.SUEZ:
        return 'Suez';
      case City.ISMAILIA:
        return 'Ismailia';
      case City.FAIYUM:
        return 'Faiyum';
      case City.DAMIETTA:
        return 'Damietta';
      case City.ASYUT:
        return 'Asyut';
      case City.MINYA:
        return 'Minya';
      case City.BENI_SUEF:
        return 'Beni Suef';
      case City.SHARQIA:
        return 'Sharqia';
      case City.DAKAHLIYA:
        return 'Dakahliya';
      case City.GHARBIA:
        return 'Gharbia';
      case City.MONUFIA:
        return 'Monufia';
      case City.KAFR_EL_SHEIKH:
        return 'Kafr El Sheikh';
      case City.BEHEIRA:
        return 'Beheira';
      case City.QENA:
        return 'Qena';
      case City.SOHAG:
        return 'Sohag';
      case City.RED_SEA:
        return 'Red Sea';
      case City.MATROUH:
        return 'Matrouh';
      case City.NEW_VALLEY:
        return 'New Valley';
      case City.NORTH_SINAI:
        return 'North Sinai';
      case City.SOUTH_SINAI:
        return 'South Sinai';
    }
  }

  String? get apiValue {
    return this == City.ALL ? null : name;
  }
}

extension DoctorSpecialityExtension on DoctorSpeciality {
  String get displayName {
    switch (this) {
      case DoctorSpeciality.ALL:
        return 'All';
      case DoctorSpeciality.CARDIOLOGY:
        return 'Cardiology';
      case DoctorSpeciality.DERMATOLOGY:
        return 'Dermatology';
      case DoctorSpeciality.NEUROLOGY:
        return 'Neurology';
      case DoctorSpeciality.ORTHOPEDICS:
        return 'Orthopedics';
      case DoctorSpeciality.OPHTHALMOLOGY:
        return 'Ophthalmology';
      case DoctorSpeciality.OTOLARYNGOLOGY:
        return 'Otolaryngology (ENT)';
    }
  }

  String? get apiValue {
    return this == DoctorSpeciality.ALL ? null : name;
  }
}

class Doctor {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String city;
  final String street;
  final String doctorSpeciality;
  final String info;
  final int patientNumber;
  final String startTime;
  final String endTime;
  final double consultationFee;
  final List<String> availableDays;
  final int id;
  final String role;

  const Doctor({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.street,
    required this.doctorSpeciality,
    required this.info,
    required this.patientNumber,
    required this.startTime,
    required this.endTime,
    required this.consultationFee,
    required this.availableDays,
    required this.id,
    required this.role,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? 'Unknown Doctor',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      doctorSpeciality: _formatSpecialty(json['doctorSpeciality'] ?? ''),
      info: json['info'] ?? '',
      patientNumber: json['patientNumber'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      consultationFee: json['consultationFee'] ?? 0,
      availableDays:
          (json['availableDays'] as List<dynamic>?)
              ?.map((day) => day.toString())
              .toList() ??
          [],
      role: json['role'] ?? 'USER',
    );
  }

  static String _formatSpecialty(String specialty) {
    switch (specialty.toUpperCase()) {
      case 'CARDIOLOGY':
        return 'Cardiologist';
      case 'DERMATOLOGY':
        return 'Dermatologist';
      case 'NEUROLOGY':
        return 'Neurologist';
      case 'ORTHOPEDICS':
        return 'Orthopedic';
      case 'OPHTHALMOLOGY':
        return 'Ophthalmologist';
      case 'OTOLARYNGOLOGY':
        return 'ENT Specialist';
      default:
        return specialty;
    }
  }

  // Add getters to match home page and doctor details expectations
  String get specialization => doctorSpeciality;
  int get fee => double.tryParse(consultationFee.toString())?.toInt() ?? 500;
}

class SearchFilters {
  final DoctorSpeciality specialty;
  final City city;

  const SearchFilters({required this.specialty, required this.city});

  SearchFilters copyWith({DoctorSpeciality? specialty, City? city}) {
    return SearchFilters(
      specialty: specialty ?? this.specialty,
      city: city ?? this.city,
    );
  }
}

abstract class DoctorRepository {
  Future<List<Doctor>> searchDoctors(String query, SearchFilters filters);
}

class ApiDoctorRepository implements DoctorRepository {
  @override
  Future<List<Doctor>> searchDoctors(
    String query,
    SearchFilters filters,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/doctors-search');

      // Build query parameters
      final queryParams = <String, String>{};

      if (query.isNotEmpty) {
        queryParams['search'] = query;
      }

      // Always include city, using 'ALL' if not specified
      queryParams['city'] = filters.city.apiValue?.toUpperCase() ?? 'ALL';

      // Always include specialty, using 'ALL' if not specified
      queryParams['doctorSpeciality'] =
          filters.specialty.apiValue?.toUpperCase() ?? 'ALL';

      // final finalUri = uri.replace(
      //   queryParameters: queryParams.isNotEmpty ? queryParams : null,
      // );

      // print('Requesting: $finalUri'); // Debug log
      print(json.encode(queryParams));

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(queryParams),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final doctors = jsonList.map((json) => Doctor.fromJson(json)).toList();
        print(doctors.length);
        return doctors;
      } else {
        throw Exception(
          'Failed to search doctors: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error searching doctors: $e'); // Debug log
      throw Exception('Failed to search doctors: $e');
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({Key? key, required this.title, this.onBackPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeUser()),
            );
          }
        },
      ),
      title: Text(title, style: AppTextStyles.title),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool isSelected;

  const FilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;

  const DoctorCard({Key? key, required this.doctor, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [Expanded(child: _buildDoctorInfo()), _buildPrice()],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.fullName,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          doctor.phoneNumber,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(doctor.specialization, style: AppTextStyles.caption),
        if (doctor.city != null) ...[
          const SizedBox(height: 4),
          Text(doctor.city!, style: AppTextStyles.caption),
        ],
        if (doctor.street != null) ...[
          const SizedBox(height: 4),
          Text(doctor.street!, style: AppTextStyles.caption),
        ],
      ],
    );
  }

  // Widget

  Widget _buildPrice() {
    return Text(
      doctor.consultationFee.toString(),
      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DoctorRepository _repository = ApiDoctorRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _errorMessage;
  SearchFilters _filters = const SearchFilters(
    specialty: DoctorSpeciality.ALL,
    city: City.ALL,
  );

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Search Doctors'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildSpecialtyFilters(),
          _buildDoctorsList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search doctors...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              onPressed: _showFilterBottomSheet,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyFilters() {
    final specialties = [
      DoctorSpeciality.ALL,
      DoctorSpeciality.CARDIOLOGY,
      DoctorSpeciality.DERMATOLOGY,
      DoctorSpeciality.NEUROLOGY,
      DoctorSpeciality.ORTHOPEDICS,
      DoctorSpeciality.OPHTHALMOLOGY,
      DoctorSpeciality.OTOLARYNGOLOGY,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  specialties
                      .map(
                        (specialty) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: specialty.displayName,
                            isSelected: specialty == _filters.specialty,
                            onTap: () => _updateFilter(specialty: specialty),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Our Doctors', style: AppTextStyles.heading),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDoctors,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_doctors.isEmpty && !_isLoading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text('No doctors found', style: AppTextStyles.caption),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          return DoctorCard(
            doctor: _doctors[index],
            onTap: () => _onDoctorTapped(_doctors[index]),
          );
        },
      ),
    );
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctors = await _repository.searchDoctors(
        _searchController.text,
        _filters,
      );
      if (mounted) {
        setState(() {
          _doctors = doctors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _loadDoctors);
  }

  Timer? _debounceTimer;

  void _updateFilter({DoctorSpeciality? specialty, City? city}) {
    setState(() {
      _filters = _filters.copyWith(specialty: specialty, city: city);
    });
    _loadDoctors();
  }

  void _onDoctorTapped(Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            filters: _filters,
            onFiltersChanged: (newFilters) {
              setState(() => _filters = newFilters);
              _loadDoctors();
            },
          ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final SearchFilters filters;
  final Function(SearchFilters) onFiltersChanged;

  const FilterBottomSheet({
    Key? key,
    required this.filters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SearchFilters _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.filters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildTitle(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [_buildSpecialtySection(), _buildCitySection()],
              ),
            ),
          ),
          _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Text('Filter Options', style: AppTextStyles.title),
    );
  }

  Widget _buildSpecialtySection() {
    final specialties = DoctorSpeciality.values;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specialty', style: AppTextStyles.body),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                specialties
                    .map(
                      (specialty) => FilterChip(
                        label: specialty.displayName,
                        isSelected: specialty == _tempFilters.specialty,
                        onTap: () => _updateSpecialty(specialty),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCitySection() {
    final cities = City.values;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('City', style: AppTextStyles.body),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                cities
                    .map(
                      (city) => FilterChip(
                        label: city.displayName,
                        isSelected: city == _tempFilters.city,
                        onTap: () => _updateCity(city),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: CustomButton(text: 'Apply Filters', onPressed: _onDonePressed),
    );
  }

  void _updateSpecialty(DoctorSpeciality specialty) {
    setState(() {
      _tempFilters = _tempFilters.copyWith(specialty: specialty);
    });
  }

  void _updateCity(City city) {
    setState(() {
      _tempFilters = _tempFilters.copyWith(city: city);
    });
  }

  void _onDonePressed() {
    widget.onFiltersChanged(_tempFilters);
    Navigator.pop(context);
  }
}

void main() {
  runApp(const Search());
}

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Search App',
      debugShowCheckedModeBanner: false,
      home: const SearchPage(),
    );
  }
}
