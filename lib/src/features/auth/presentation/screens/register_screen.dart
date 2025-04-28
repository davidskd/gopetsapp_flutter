import 'dart:async'; // For Timer

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:dropdown_search/dropdown_search.dart'; // Import dropdown_search
import 'package:uywapets_flutter/src/features/master/domain/models/country.dart'; // Importar modelo Country
import 'package:uywapets_flutter/src/features/master/domain/models/state.dart'; // Importar modelo State
import 'package:uywapets_flutter/src/shared/widgets/country_dropdown.dart'; // Importar componente CountryDropdown
import 'package:uywapets_flutter/src/shared/widgets/state_dropdown.dart'; // Importar componente StateDropdown

// TODO: Import necessary providers (AuthService, MasterService, etc.)
// import 'package:uywapets_flutter/src/features/auth/data/providers/auth_providers.dart'; // Example path
// import 'package:uywapets_flutter/src/features/master/data/providers/master_providers.dart'; // Example path
// TODO: Move these models to appropriate domain layer files

// Eliminamos la clase Country duplicada aquí ya que estamos importando el modelo correcto

// Eliminamos la clase Region ya que ahora usamos el modelo State
// class Region { // Using Region instead of State/Department
//   final String id;
//   final String name;
//   Region({required this.id, required this.name});
//
//    @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is Region && runtimeType == other.runtimeType && id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
// TODO: Import route names if defined elsewhere
// import 'package:uywapets_flutter/src/shared/routing/app_routes.dart'; // Example path


class RegisterScreen extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  const RegisterScreen({super.key});

  static const String route = '/register'; // Define route name

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState(); // Change to ConsumerState
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> { // Change to ConsumerState
  final _formKey = GlobalKey<FormState>();
  int _step = 1; // Start at step 1

  // Form Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController(); // Will show formatted date
  // Step 3 Controllers
  final _phonePrefixController = TextEditingController(text: '51'); // Default prefix
  final _phoneNumberController = TextEditingController();
  final _otpController = TextEditingController();


  // State variables
  bool _viewPassword = false;
  DateTime? _selectedDate;
  String? _selectedGender;
  Country? _selectedCountry; // Use Country object
  States? _selectedState;   // Use State object
  // Step 3 State (SMS)
  bool _isSendingSms = false;
  bool _canResendSms = true; // Start as true, becomes false after sending
  int _smsResendTimerSeconds = 60; // Initial duration
  Timer? _smsResendTimer;
  bool _isVerifyingSmsOtp = false; // Loading state for SMS OTP verification
  // Step 4 State (Email)
  bool _isSendingEmail = false;
  bool _canResendEmail = true; // Start as true
  int _emailResendTimerSeconds = 180; // Match Ionic timer
  Timer? _emailResendTimer;
  bool _isVerifyingEmailOtp = false; // Loading state for Email OTP verification

  // General Loading State
  bool _isLoading = false; // For general loading like step 1 registration
  String? _userId; // To store user ID after step 1 registration

  // TODO: Remove dummy data once providers are integrated
  // final List<Map<String, String>> _countries = [
  //   {'id': '1', 'name': 'Perú'},
  //   {'id': '2', 'name': 'Colombia'},
  // ]; // Dummy data
  // final List<Map<String, String>> _states = []; // Dummy data, depends on country

  // TODO: Define Riverpod providers for countries and states
  // Example:
  // final countriesProvider = FutureProvider<List<Country>>((ref) async {
  //   final masterService = ref.watch(masterServiceProvider);
  //   return masterService.getCountries();
  // });
  // final statesProvider = FutureProvider.family<List<Region>, String>((ref, countryId) async {
  //   final masterService = ref.watch(masterServiceProvider);
  //   return masterService.getRegions(countryId);
  // });


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _phonePrefixController.dispose();
    _phoneNumberController.dispose();
    _otpController.dispose(); // Shared OTP controller for now
    _smsResendTimer?.cancel();
    _emailResendTimer?.cancel(); // Cancel email timer on dispose
    super.dispose();
  }

  // --- SMS Timer Logic ---
  void _startSmsResendTimer() {
    _smsResendTimer?.cancel(); // Cancel any existing timer
    setState(() {
      _isSendingSms = true; // Indicate loading/waiting
      _canResendSms = false;
      _smsResendTimerSeconds = 60; // Reset timer
    });

    _smsResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_smsResendTimerSeconds > 0) {
          _smsResendTimerSeconds--;
        } else {
          timer.cancel();
          _isSendingSms = false; // No longer waiting
          _canResendSms = true; // Allow resend
        }
      });
     });
   }

   Future<void> _sendSmsOtp() async {
     // Validate phone number fields specifically (might need a separate key for step 3 form)
     // For now, assume validation happens before calling or rely on button state
     final phone = _phoneNumberController.text;
     final prefix = _phonePrefixController.text;
     if (phone.isEmpty || prefix.isEmpty || phone.length != 9 || prefix.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa un prefijo y número de teléfono válidos.')),
        );
       return;
     }

     // No need to set _isSendingSms here, _startSmsResendTimer does it.
     // setState(() => _isSendingSms = true); // Timer handles this

     try {
       // TODO: Replace with actual AuthService provider and method
       // final authService = ref.read(authServiceProvider);
       final fullPhoneNumber = '+$prefix$phone';
       print('Attempting to send SMS OTP to $fullPhoneNumber');
       // final success = await authService.sendSmsOtp(phoneNumber: fullPhoneNumber); // Example call

       // --- Placeholder Success ---
       await Future.delayed(const Duration(seconds: 1)); // Simulate network call
       final success = true; // Assume success for placeholder
       // --- End Placeholder ---

       if (success && mounted) {
          print('SMS OTP send initiated successfully.');
          _startSmsResendTimer(); // Start timer ONLY on successful initiation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código SMS enviado con éxito.')),
          );
       } else if (mounted) {
          // Handle API returning false/error without throwing exception
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al enviar el código SMS.')),
          );
          // Reset timer state if send failed immediately
          setState(() {
             _isSendingSms = false;
             _canResendSms = true;
          });
       }

     } catch (e) {
       print('Error sending SMS OTP: $e');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error al enviar SMS: ${e.toString()}')),
         );
         // Reset timer state on error
         setState(() {
            _isSendingSms = false;
            _canResendSms = true;
         });
       }
     }
      // No finally block needed to set _isSendingSms = false, timer handles it
    }

    Future<void> _verifySmsOtp() async {
      final otp = _otpController.text;
      if (otp.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa el código OTP de 4 dígitos.')),
        );
        return;
      }

      setState(() => _isVerifyingSmsOtp = true);

      try {
        // TODO: Replace with actual AuthService provider and method
        // final authService = ref.read(authServiceProvider);
        // final success = await authService.verifySmsOtp(otp: otp); // Example call

        // --- Placeholder Success ---
        await Future.delayed(const Duration(seconds: 1)); // Simulate network call
        final success = true; // Assume success for placeholder
        // --- End Placeholder ---

        if (success && mounted) {
          print('SMS OTP verified successfully.');
          // TODO: Define route names properly (e.g., AppRoutes.modulos)
          context.go('/modulos'); // Navigate to main app screen on success
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código OTP incorrecto.')),
          );
        }
      } catch (e) {
        print('Error verifying SMS OTP: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al verificar OTP: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isVerifyingSmsOtp = false);
        }
      }
    }
    // --- End SMS Timer Logic ---

  // --- Email Timer Logic ---
   void _startEmailResendTimer() {
    _emailResendTimer?.cancel();
    setState(() {
      _isSendingEmail = true;
      _canResendEmail = false;
      _emailResendTimerSeconds = 180; // Reset timer
    });

    _emailResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_emailResendTimerSeconds > 0) {
          _emailResendTimerSeconds--;
        } else {
          timer.cancel();
          _isSendingEmail = false;
          _canResendEmail = true;
        }
      });
     });
   }

   Future<void> _sendEmailOtp() async {
     final email = _emailController.text;
     // User ID should be set after step 1, check if it exists
     if (_userId == null || email.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error interno: No se pudo obtener el email o ID de usuario.')),
       );
       return;
     }

     // Timer starts loading state
     // setState(() => _isSendingEmail = true);

     try {
       // TODO: Replace with actual AuthService provider and method
       // final authService = ref.read(authServiceProvider);
       print('Attempting to send Email OTP to $email for user $_userId');
       // final success = await authService.sendEmailOtp(email: email, userId: _userId!); // Example call

       // --- Placeholder Success ---
       await Future.delayed(const Duration(seconds: 1)); // Simulate network call
       final success = true; // Assume success
       // --- End Placeholder ---

       if (success && mounted) {
         print('Email OTP send initiated successfully.');
         _startEmailResendTimer(); // Start timer ONLY on success
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Código de correo enviado con éxito.')),
         );
       } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error al enviar el código por correo.')),
         );
         setState(() {
           _isSendingEmail = false;
           _canResendEmail = true;
         });
       }
     } catch (e) {
       print('Error sending Email OTP: $e');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error al enviar correo: ${e.toString()}')),
         );
         setState(() {
           _isSendingEmail = false;
           _canResendEmail = true;
         });
       }
     }
   }

   Future<void> _verifyEmailOtp() async {
     final otp = _otpController.text;
     if (otp.length != 4) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Por favor ingresa el código OTP de 4 dígitos.')),
       );
       return;
     }
      // Check for userId again
     if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error interno: No se pudo obtener el ID de usuario.')),
       );
       return;
     }

     setState(() => _isVerifyingEmailOtp = true);

     try {
       // TODO: Replace with actual AuthService provider and method
       // final authService = ref.read(authServiceProvider);
       print('Verifying Email OTP: $otp for user $_userId');
       // final success = await authService.verifyEmailOtp(otp: otp, userId: _userId!); // Example call

       // --- Placeholder Success ---
       await Future.delayed(const Duration(seconds: 1)); // Simulate network call
       final success = true; // Assume success
       // --- End Placeholder ---

       if (success && mounted) {
         print('Email OTP verified successfully.');
         // TODO: Define route names properly
         context.go('/modulos'); // Navigate to main app screen
       } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Código OTP incorrecto.')),
         );
       }
     } catch (e) {
       print('Error verifying Email OTP: $e');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error al verificar OTP: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isVerifyingEmailOtp = false);
        }
      }
    }
    // --- End Email Timer Logic ---

  // Removed stray print and closing brace from here

  Future<void> _goToNextStep() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }

    setState(() => _isLoading = true); // Show loading indicator

    try {
      // TODO: Replace with actual AuthService provider and method
      // final authService = ref.read(authServiceProvider); // Assuming provider exists
      // final response = await authService.register(
      //   username: _usernameController.text,
      //   password: _passwordController.text,
      //   name: _nameController.text,
      //   email: _emailController.text,
      //   birthday: _selectedDate, // Send DateTime object
      //   gender: _selectedGender,
      //   countryId: _selectedCountryId,
      //   stateId: _selectedStateId,
      // );

       // --- Placeholder Success ---
       await Future.delayed(const Duration(seconds: 1)); // Simulate network call
       print('Registration successful (Placeholder)');
       // TODO: Handle successful registration response (e.g., store user ID if needed for OTP)
       // TODO: Extract userId from the actual response model
       _userId = 'placeholder_user_id_123'; // Store user ID (placeholder)
       // --- End Placeholder ---

       setState(() {
        _step = 2; // Move to next step on success
      });

    } catch (e) {
      // TODO: Improve error handling (show specific messages)
      print('Registration failed: $e');
      if (mounted) { // Check if the widget is still in the tree
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error en el registro: ${e.toString()}')), // Show error
         );
      }
    } finally {
       if (mounted) {
         setState(() => _isLoading = false); // Hide loading indicator
       }
        }
     }

     void _goToPreviousStep() {
        // Clear OTP field when going back from step 3 or 4
        if (_step == 3 || _step == 4) {
           _otpController.clear();
        }
        // Clear phone fields when going back from step 3
        if (_step == 3) {
           _phoneNumberController.clear();
           // Optionally reset prefix if needed: _phonePrefixController.text = '51';
        }

        if (_step > 1) {
          setState(() {
            _step--;
          });
        } else {
          // Navigate back from step 1
          if (context.canPop()) {
             context.pop();
          } else {
             // Fallback or specific navigation if cannot pop (e.g., deep link)
             // TODO: Confirm the correct route to navigate back to (e.g., PreLoginScreen.route)
             context.go('/prelogin'); // Navigate to prelogin as a fallback
          }
        }
     }

     Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(DateTime.now().year - 18), // Default to 18 years ago
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked); // Update text field
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Consistent back icon
          onPressed: _goToPreviousStep,
        ),
         title: Text('Registro - Paso $_step'), // Dynamic title
       ),
       // Usar SingleChildScrollView para evitar desbordamientos
       body: Padding( // Added padding around the Column
         padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               _buildProgressIndicator(), // Add progress indicator here
               const SizedBox(height: 16), // Add some spacing
               // Form is now inside the SingleChildScrollView
               Form(
                 key: _formKey,
                 child: _buildStepContent(), // Build content based on current step
                ),
              ],
            ),
          ),
        ),
      );
  }

  // Builds the visual progress indicator
  Widget _buildProgressIndicator() {
    const totalSteps = 4; // Total number of steps
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          int stepNumber = index + 1;
          bool isActive = stepNumber == _step;
          bool isCompleted = stepNumber < _step;
          Color color = isCompleted
              ? Theme.of(context).primaryColor
              : isActive
                  ? Theme.of(context).primaryColor.withOpacity(0.8)
                  : Colors.grey.shade300;
          Color textColor = isCompleted || isActive ? Colors.white : Colors.black54;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isActive ? Border.all(color: Theme.of(context).primaryColorDark, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Builds the content for the current step
  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _buildStep1Form();
      case 2:
        return _buildStep2VerificationOptions();
      case 3:
        return _buildStep3SmsOtp();
      case 4:
        return _buildStep4EmailOtp();
      default:
        return Center(child: Text('Paso $_step no implementado'));
     }
   }

 
   // Builds the form for Step 1
   Widget _buildStep1Form() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Crear Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Completa los siguientes campos para crear tu cuenta y explorar con GO PETS!'),
        const SizedBox(height: 24),

        // Username
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un nombre de usuario';
            }
            if (value.length < 3) {
              return 'Debe tener al menos 3 caracteres';
            }
            // Basic pattern check (no spaces, simple chars) - adjust as needed
            if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
               return 'No debe tener espacios ni caracteres especiales';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: !_viewPassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(_viewPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _viewPassword = !_viewPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 6) {
              return 'Debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Name
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nombre y Apellido'),
           validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre y apellido';
            }
             if (value.length < 3) {
              return 'Debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Correo Electrónico'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un correo electrónico';
            }
            // Basic email pattern validation
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Birthday
        TextFormField(
          controller: _birthdayController,
          readOnly: true, // Make it read-only
          decoration: const InputDecoration(
            labelText: 'Fecha de Nacimiento',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () => _selectDate(context), // Show date picker on tap
          validator: (value) {
             if (value == null || value.isEmpty) {
               return 'Por favor selecciona tu fecha de nacimiento';
             }
             return null;
           },
        ),
        const SizedBox(height: 16),

        // Gender
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(labelText: 'Género'),
          items: const [
            DropdownMenuItem(value: 'M', child: Text('Masculino')),
            DropdownMenuItem(value: 'F', child: Text('Femenino')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
           validator: (value) {
             if (value == null) {
               return 'Por favor selecciona tu género';
             }
             return null;
            },
         ),
         const SizedBox(height: 16),

         // País con nuestro componente CountryDropdown
         CountryDropdown(
           label: 'País',
           selectedCountry: _selectedCountry,
           onChanged: (country) {
             setState(() {
               _selectedCountry = country;
               // Al cambiar el país, limpiamos la región seleccionada
               _selectedState = null;
             });
           },
           isRequired: true,
           validator: (country) {
             if (country == null) {
               return 'Por favor selecciona un país';
             }
             return null;
           },
         ),
         const SizedBox(height: 16),
         
         // Región con nuestro componente StateDropdown
         StateDropdown(
           label: 'Provincia',
           countryRefId: _selectedCountry?.countryRefId,
           selectedState: _selectedState,
           onChanged: (state) {
             setState(() {
               _selectedState = state;
             });
           },
           isRequired: true,
           validator: (state) {
             if (state == null) {
               return 'Por favor selecciona una provincia';
             }
             return null;
           },
         ),
         const SizedBox(height: 32),

         // Submit Button
         ElevatedButton(
           onPressed: _isLoading ? null : _goToNextStep, // Disable button when loading
           style: ElevatedButton.styleFrom(
             padding: const EdgeInsets.symmetric(vertical: 16),
             textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           ),
           child: _isLoading
               ? const SizedBox(
                   height: 24, // Match text height
                   width: 24,
                   child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                 )
               : const Text('Registrarse'),
         ),
         const SizedBox(height: 16),
         // Link to Login (Optional, but good practice)
         TextButton(
           onPressed: () {
             // TODO: Navigate to PreLogin or Login using GoRouter
             // GoRouter.of(context).go('/prelogin');
           },
           child: const Text('¿Ya tienes cuenta? Inicia Sesión'),
         ),
      ],
    );
  }

  // Builds the options for Step 2
  Widget _buildStep2VerificationOptions() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
         const Text('Verificación de Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
         const SizedBox(height: 8),
         const Text('Selecciona Método de verificación'),
         const SizedBox(height: 24),
         ListTile(
           leading: const Icon(Icons.phone_android),
           title: const Text('Vía SMS'),
           trailing: const Icon(Icons.chevron_right),
           onTap: () {
             setState(() {
               _step = 3; // Go to SMS step
             });
           },
         ),
         const Divider(),
         ListTile(
           leading: const Icon(Icons.email),
           title: const Text('Vía Correo'),
           trailing: const Icon(Icons.chevron_right),
           onTap: () {
             setState(() {
               _step = 4; // Go to Email step
             });
           },
         ),
       ],
     );
  }

  // Builds the UI for Step 3: SMS OTP Verification
  Widget _buildStep3SmsOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Verificación por SMS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Se enviará un código de seguridad de 4 dígitos por SMS al teléfono que ingreses para verificar tu cuenta.'),
        const SizedBox(height: 24),

        // Phone Number Input Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to top for validation messages
          children: [
            // Prefix
            SizedBox(
              width: 80, // Adjust width as needed
              child: TextFormField(
                controller: _phonePrefixController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Prefijo',
                  // TODO: Add country flag based on prefix?
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Req.';
                  if (value.length < 2) return 'Inv.';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            // Phone Number
            Expanded(
              child: TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 9, // Match Ionic input
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  counterText: "", // Hide the default counter
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu teléfono';
                  }
                  if (value.length != 9) {
                    return 'Debe tener 9 dígitos';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Send SMS Button
        ElevatedButton(
          onPressed: _isSendingSms ? null : _sendSmsOtp, // Disable while sending/waiting
          child: _isSendingSms
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 16),
                    Text('Esperar (${_smsResendTimerSeconds}s)'),
                  ],
                )
              : const Text('Enviar SMS'),
        ),
        const SizedBox(height: 32),

        // --- OTP Input Section ---
        const Text('Verifica tu Teléfono', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
         const SizedBox(height: 8),
         const Text('Ingrese el código de seguridad de 4 dígitos que acabamos de enviar a tu teléfono.'),
          const SizedBox(height: 16),

         // Use flutter_otp_text_field
         OtpTextField(
           numberOfFields: 4,
           borderColor: Theme.of(context).primaryColor,
           // styles: [TextStyle(fontSize: 24)], // Optional: Apply specific style
           showFieldAsBox: true, // Use boxes
           fieldWidth: 50, // Adjust width as needed
           //runs when every textfield is filled
           onSubmit: (String verificationCode){
               _otpController.text = verificationCode; // Update the controller
               // Optionally trigger verification immediately, or rely on the button
               // _verifySmsOtp();
           }, // end onSubmit
         ),
         const SizedBox(height: 24),

          // Verify Button
         ElevatedButton(
           // Enable only after SMS has been sent and not currently verifying
           onPressed: (_canResendSms || _isSendingSms || _isVerifyingSmsOtp) ? null : _verifySmsOtp,
           style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
           child: _isVerifyingSmsOtp
               ? const SizedBox(
                   height: 24, width: 24,
                   child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)
                 )
               : const Text('Verificar'),
         ),
       ],
    );
  }

  // Builds the UI for Step 4: Email OTP Verification
  Widget _buildStep4EmailOtp() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
         const Text('Verificación por Correo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
         const SizedBox(height: 8),
         const Text('Se enviará un código de seguridad de 4 dígitos al email que registraste para verificar tu cuenta.'),
         const SizedBox(height: 24),

         // Display Registered Email (Read-only)
         TextFormField(
           controller: _emailController, // Use controller from step 1
           readOnly: true,
           decoration: const InputDecoration(
             labelText: 'Correo Registrado',
             prefixIcon: Icon(Icons.email_outlined),
             border: InputBorder.none, // Make it look like text
             filled: false, // No background fill
           ),
           style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
         ),
         const SizedBox(height: 24),

         // Send Email Button
         ElevatedButton(
           onPressed: _isSendingEmail ? null : _sendEmailOtp,
           child: _isSendingEmail
               ? Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                     const SizedBox(width: 16),
                     Text('Esperar (${_emailResendTimerSeconds}s)'),
                   ],
                 )
               : const Text('Enviar Correo'),
         ),
         const SizedBox(height: 32),

         // --- OTP Input Section ---
         const Text('Verifica tu Correo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Ingrese el código de seguridad de 4 dígitos que acabamos de enviar a tu correo.'),
           const SizedBox(height: 16),

          // Use flutter_otp_text_field (reusing the same logic)
          OtpTextField(
            numberOfFields: 4,
            borderColor: Theme.of(context).primaryColor,
            // styles: [TextStyle(fontSize: 24)], // Optional: Apply specific style
            showFieldAsBox: true, // Use boxes
            fieldWidth: 50, // Adjust width as needed
            //runs when every textfield is filled
            onSubmit: (String verificationCode){
                _otpController.text = verificationCode; // Update the controller
                // Optionally trigger verification immediately
                // _verifyEmailOtp();
            }, // end onSubmit
          ),
          const SizedBox(height: 24),

          // Verify Button
         ElevatedButton(
           // Enable only after Email has been sent and not currently verifying
           onPressed: (_canResendEmail || _isSendingEmail || _isVerifyingEmailOtp) ? null : _verifyEmailOtp,
           style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
           child: _isVerifyingEmailOtp
               ? const SizedBox(
                   height: 24, width: 24,
                   child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)
                 )
               : const Text('Verificar'),
         ),
       ],
     );
  }

}
