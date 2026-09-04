import 'package:docs_appointment/sign_up/sign_up.dart';
import 'package:docs_appointment/widget/custom_button.dart';
import 'package:docs_appointment/widget/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../service/app_state.dart';
import '../theme/app_theme.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState> ();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.patient;
  

  @override
  void dispose (){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _handleLogin() async{
    if (_formkey.currentState!.validate()){
      final appState = Provider.of<AppState>(context,listen:false);
      final success = await appState.login(
          _emailController.text,
          _passwordController.text,
          _selectedRole
      );
      // Navigation will be handled in main.dart dynamically by checking currentUser

    }
  }

  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(isDark ? 0.15 : 0.08)
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.success.withOpacity(isDark ? 0.1 : 0.05)
              ),
            ),
          ),

          SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.accentShadow,


                            ),
                            child: const Icon(
                              Icons.healing_rounded,
                              color: Colors.white,
                              size: 28,

                            ),
                          ),

                          const SizedBox(width: 12),
                          Text(
                            "MediFred",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.backgroundLight : AppTheme.blue ,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Text(
                        "Healthcare Scheduling, Simplified",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppTheme.backgroundLight: AppTheme.textMutedLight,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                     // Patient / Doctor Selector
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.blue : AppTheme.backColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState (() => _selectedRole = UserRole.patient,


                              ),
                            child:AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.patient
                                    ? (isDark ? const Color (0xFF1E293B): Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedRole == UserRole.patient && !isDark
                                  ? AppTheme.premiumShadow
                                    : [],
                              ),

                              alignment: Alignment.center,
                              child: Text(
                                "Patient",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRole == UserRole.patient
                                    ? AppTheme.accent
                                      : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                                ),
                              ),
                            ) ,
                            )
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState (() => _selectedRole = UserRole.doctor),
                                child:AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: _selectedRole == UserRole.doctor
                                        ?(isDark ? const Color(0xFF1E293B) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _selectedRole == UserRole.doctor && !isDark
                                      ? AppTheme.premiumShadow
                                        : [],
                                  ),

                                  alignment: Alignment.center,
                                  child: Text(
                                    "Doctor",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedRole == UserRole.doctor
                                        ? AppTheme.accent
                                          : (isDark ? AppTheme.textMutedLight : AppTheme.textMutedLight),
                                    ),
                                  ),
                                ) ,
                            )
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      // Form
                      Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              labelText: "Email Address",
                              hintText: "Enter your email",
                              prefixIcon: Icons.email_outlined,
                              keyboardTypes: TextInputType.emailAddress,
                              validator: (val){
                              if (val == null || val.isEmpty) return "Please enter your email";
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                        return "Please enter a valid email address";
          }
                      return null;
          },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                            controller: _passwordController,
                                labelText: "Password",
                                hintText:"Enter your password",
                                prefixIcon: Icons.lock_outlined,
                                isPassword : true,
                              validator: (val){
                              if (val == null || val.isEmpty)return "please enter your password";
                              if (val.length<6)return"password must be at least 6 characters ";
                              return null;
                              },
                            ),

                            const SizedBox(height: 32),
                            Consumer<AppState>(
                              builder: (context, state , child) {
                                return CustomButton(
                                  text: "Sign In",
                                  isLoading: state.isLoading,
                                  onPressed: _handleLogin,
                                );
                              }

                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 23),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Dont have an account",
                            style: TextStyle(
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),

                          TextButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text (
                              "Sign up",
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],

                  ),
                ),

              )
          )
        ],
      ),
    );
  }
}