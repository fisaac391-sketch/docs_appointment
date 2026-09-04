import 'package:docs_appointment/models/models.dart';
import 'package:docs_appointment/service/app_state.dart';
import 'package:docs_appointment/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widget/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formkey =GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedtRole = UserRole.patient;
  String _selectedSpecialty = "General Medicine";

  final List<String> _specialties = [
    "General Medicine",
    "Cardiology",
    "Pediatrics",
    "Darmatology",
    "Neurology",
  ];


  @override
  void dispose(){
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async{
    if (_formkey.currentState!.validate()){
      final appState = Provider.of<AppState>(context,listen:false);
      final success = await appState.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _selectedtRole,
        specialty: _selectedtRole==UserRole.doctor?_selectedSpecialty:null,

      );
      if (success && mounted){
        //pop back to login screen, which will automatically navigate to home
        Navigator.pop(context);
      }
    }
  }
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness==Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () =>Navigator.pop(context),

        ),
      ),

      body: Stack(
        children: [
          //Background decorations
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(isDark? 0.15:0.08),
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
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark? Colors.white:AppTheme.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8,),
                    Text(
                      "Join the modern medical network",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark?AppTheme.textMutedDark:AppTheme.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 32,),
                    //Patient/ Doctor selector
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark?const Color(0xFF172A):const Color(0xFF2E8F0).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: ()=>setState(() =>_selectedtRole=UserRole.patient),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: _selectedtRole==UserRole.patient
                                      ? (isDark? const Color(0xFF1E293B) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedtRole==UserRole.patient&&isDark
                                    ?AppTheme.premiumShadow
                                      :[],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Patient",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedtRole==UserRole.patient
                                      ?AppTheme.accent
                                        :(isDark?AppTheme.textMutedDark:AppTheme.textMutedLight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: ()=>setState(()=>_selectedtRole=UserRole.doctor),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: _selectedtRole==UserRole.doctor
                                      ?(isDark?const Color(0xFF1E293B):Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedtRole==UserRole.doctor&&isDark
                                    ?AppTheme.premiumShadow
                                      :[],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Doctor",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedtRole==UserRole.doctor
                                      ?AppTheme.accent
                                        :(isDark?AppTheme.textMutedDark:AppTheme.textMutedLight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24,),

                    //Form
                    Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            labelText:"Full Name",
                            hintText: "Enter Your Full Name",
                            prefixIcon:Icons.person_outline_rounded,
                            validator:(val){
                              if (val==null || val.isEmpty) return"Please enter your name";
                              return null;
                            },

                          ),
                          const SizedBox(height: 20,),
                          CustomTextField(
                            controller: _emailController,
                            labelText: "Email Address",
                            hintText: "Enter your email",
                            prefixIcon: Icons.email_outlined,
                            isPassword: true,
                            validator: (val){
                              if (val == null || val.isEmpty)return "please enter a password";
                              if (val.length<6) return"please enter at least 6 characters";
                              return null;
                            },
                          ),
                         // Doctor Specialty selection fields
                          if (_selectedtRole == UserRole.doctor)...[
                          const SizedBox(height: 20,),
                          DropdownButtonFormField<String>(
                            value: _selectedSpecialty,
                            decoration: InputDecoration(
                              labelText: "Field of Practice",
                              filled: true,
                              fillColor: isDark? AppTheme.blue : AppTheme.backgroundLight,
                            prefixIcon: const Icon(Icons.school_outlined),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16,),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white10 : Colors.black12,
                                width: 1.5,
                              ),
                            )  ,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppTheme.accent,
                                  width: 2,
                                )
                              )
                            ), items: _specialties.map((specialty)
                          {
                            return DropdownMenuItem<String>(
                              value: specialty,
                              child: Text(specialty),
                            );
                          }).toList(),
                            dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            onChanged: (val) {
                              if (val !=null){
                                setState(() => _selectedSpecialty = val);
                              }
                            },
                          ),
                          ],
                          const SizedBox(height: 32),
                          Consumer<AppState>(
                            builder: (context,state,child){
                              return CustomButton(
                                text: "Register",
                                isLoading: state.isLoading,
                                onPressed: _handleRegister,
                              );
                            }
                          )
                        ],
                      ),

                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
