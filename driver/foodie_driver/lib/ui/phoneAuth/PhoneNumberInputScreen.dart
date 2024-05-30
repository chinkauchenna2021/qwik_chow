import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as Easy;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/container/ContainerScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

File? _image;
File? _carImage;

class PhoneNumberInputScreen extends StatefulWidget {
  final bool login;

  const PhoneNumberInputScreen({Key? key, required this.login}) : super(key: key);

  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();
  String? firstName, lastName, carName, carPlate, _phoneNumber, _verificationID;
  bool _isPhoneValid = false, _codeSent = false;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid && !widget.login) {
      retrieveLostData();
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: Form(
            key: _key,
            autovalidateMode: _validate,
            child: Column(
              children: <Widget>[
                Align(
                    alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.topLeft : Alignment.topRight,
                    child: Text(
                      widget.login ? 'Sign In'.tr() : 'Create new account'.tr(),
                      style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 25.0),
                    ).tr()),

                /// user profile picture,  this is visible until we verify the
                /// code in case of sign up with phone number
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
                  child: Visibility(
                    visible: !_codeSent && !widget.login,
                    child: SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _image == null
                                        ? Image.asset(
                                            'assets/images/placeholder.jpg',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 80,
                                right: 0,
                                child: FloatingActionButton(
                                    heroTag: 'profileImage',
                                    backgroundColor: Color(COLOR_ACCENT),
                                    child: Icon(
                                      CupertinoIcons.camera,
                                      color: isDarkMode(context) ? Colors.black : Colors.white,
                                    ),
                                    mini: true,
                                    onPressed: () => _onCameraClick(true)),
                              )
                            ],
                          ),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey.shade400,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: _carImage == null
                                        ? Image.asset(
                                            'assets/images/car_default_image.png',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _carImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 80,
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'carImage',
                                  backgroundColor: Color(COLOR_ACCENT),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: isDarkMode(context) ? Colors.black : Colors.white,
                                  ),
                                  mini: true,
                                  onPressed: () => _onCameraClick(false),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// user first name text field , this is visible until we verify the
                /// code in case of sign up with phone number
                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        cursorColor: Color(COLOR_PRIMARY),
                        textAlignVertical: TextAlignVertical.center,
                        validator: validateName,
                        controller: _firstNameController,
                        onSaved: (String? val) {
                          firstName = val;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: 'First Name'.tr(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// last name of the user , this is visible until we verify the
                /// code in case of sign up with phone number
                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        validator: validateName,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Color(COLOR_PRIMARY),
                        onSaved: (String? val) {
                          lastName = val;
                        },
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: 'Last Name'.tr(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        validator: validateEmptyField,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Color(COLOR_PRIMARY),
                        onSaved: (String? val) {
                          carName = val;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: 'Car Model'.tr(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        validator: validateEmptyField,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Color(COLOR_PRIMARY),
                        onSaved: (String? val) {
                          carPlate = val;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: 'Car Plate'.tr(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// user phone number,  this is visible until we verify the code
                Visibility(
                  visible: !_codeSent,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.grey.shade200)),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) => _phoneNumber = number.phoneNumber,
                        onInputValidated: (bool value) => _isPhoneValid = value,
                        ignoreBlank: true,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        inputDecoration: InputDecoration(
                          hintText: 'Phone Number'.tr(),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        inputBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        initialValue: PhoneNumber(isoCode: 'US'),
                        selectorConfig: SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
                      ),
                    ),
                  ),
                ),

                /// code validation field, this is visible in case of sign up with
                /// phone number and the code is sent
                Visibility(
                  visible: _codeSent,
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                    child: PinCodeTextField(
                      length: 6,
                      appContext: context,
                      keyboardType: TextInputType.phone,
                      backgroundColor: Colors.transparent,
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 40,
                          fieldWidth: 40,
                          activeColor: Color(COLOR_PRIMARY),
                          activeFillColor: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade100,
                          selectedFillColor: Colors.transparent,
                          selectedColor: Color(COLOR_PRIMARY),
                          inactiveColor: Colors.grey.shade600,
                          inactiveFillColor: Colors.transparent),
                      enableActiveFill: true,
                      onCompleted: (v) {
                        _submitCode(v);
                      },
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ),
                ),

                /// the main action button of the screen, this is hidden if we
                /// received the code from firebase
                /// the action and the title is base on the state,
                /// * Sign up with email and password: send email and password to
                /// firebase
                /// * Sign up with phone number: submits the phone number to
                /// firebase and await for code verification
                Visibility(
                  visible: !_codeSent,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(COLOR_PRIMARY),
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                              color: Color(COLOR_PRIMARY),
                            ),
                          ),
                        ),
                        onPressed: () => _signUp(),
                        child: Text(
                          'Send code'.tr(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode(context) ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'OR',
                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                    ).tr(),
                  ),
                ),

                /// switch between sign up with phone number and email sign up states
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    widget.login ? 'Login with E-mail'.tr() : 'Sign up with E-mail'.tr(),
                    style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// submits the code to firebase to be validated, then get get the user
  /// object from firebase database
  /// @param code the code from input from code field
  /// creates a new user from phone login
  void _submitCode(String code) async {
    await showProgress(context, widget.login ? 'Logging in...'.tr() : 'Signing up...'.tr(), false);
    try {
      if (_verificationID != null) {
        dynamic result = await FireStoreUtils.firebaseSubmitPhoneNumberCode(_verificationID!, code, _phoneNumber!,
            firstName: _firstNameController.text,
            carImage: _carImage,
            carPlates: carPlate ?? '',
            carName: carName ?? '',
            image: _image,
            lastName: _lastNameController.text);
        await hideProgress();
        if (result != null && result is User) {
          if (result.active) {
            MyAppState.currentUser = result;
            pushAndRemoveUntil(context, ContainerScreen(), false);
          } else {
            showAlertDialog(context, "notLogIn".tr(), 'User not activated yet.'.tr(), true);
          }
        } else if (result != null && result is String) {
          showAlertDialog(context, 'Failed'.tr(), result, true);
        } else {
          showAlertDialog(context, 'Failed'.tr(), "notCreatePhoneNumber".tr(), true);
        }
      } else {
        await hideProgress();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("NotVerificationID".tr()),
          duration: Duration(seconds: 6),
        ));
      }
    } on auth.FirebaseAuthException catch (exception) {
      hideProgress();
      String message = "errorOccurredTryAgain".tr();
      switch (exception.code) {
        case 'invalid-verification-code':
          message = "InvalidCodeExpired".tr();
          break;
        case 'user-disabled':
          message = "userDisabled".tr();
          break;
        default:
          message = "errorOccurredTryAgain".tr();
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.tr(),
          ),
        ),
      );
    } catch (e, s) {
      print('_PhoneNumberInputScreenState._submitCode $e $s');
      hideProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "errorOccurredTryAgain".tr(),
          ),
        ),
      );
    }
  }

  /// used on android by the image picker lib, sometimes on android the image
  /// is lost
  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
      });
    }
  }

  /// a set of menu options that appears when trying to select a profile
  /// image from gallery or take a new pic
  _onCameraClick(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add profile picture'.tr() : 'Add Car Image'.tr(),
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage ? _image = File(image.path) : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage ? _image = File(image.path) : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isUserImage ? _image = null : _carImage = null;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _signUp() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      if (_isPhoneValid)
        await _submitPhoneNumber(_phoneNumber!);
      else
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("InvalidPhoneTryAgain".tr()),
        ));
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  /// sends a request to firebase to create a new user using phone number and
  /// navigate to [ContainerScreen] after wards
  _submitPhoneNumber(String phoneNumber) async {
    //send code
    await showProgress(context, 'Sending code...'.tr(), true);
    await FireStoreUtils.firebaseSubmitPhoneNumber(
      phoneNumber,
      (String verificationId) {
        if (mounted) {
          hideProgress();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Code verification timeout, request new code.'.tr(),
              ),
            ),
          );
          setState(() {
            _codeSent = false;
          });
        }
      },
      (String? verificationId, int? forceResendingToken) {
        if (mounted) {
          hideProgress();
          _verificationID = verificationId;
          setState(() {
            _codeSent = true;
          });
        }
      },
      (auth.FirebaseAuthException error) {
        if (mounted) {
          hideProgress();
          print('${error.message} ${error.stackTrace}');
          String message = "errorOccurredTryAgain".tr();
          switch (error.code) {
            case 'invalid-verification-code':
              message = "InvalidCodeExpired".tr();
              break;
            case 'user-disabled':
              message = "userDisabled".tr();
              break;
            default:
              message = "errorOccurredTryAgain".tr();
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.tr(),
              ),
            ),
          );
        }
      },
      (auth.PhoneAuthCredential credential) async {
        if (mounted) {
          auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(credential);
          User? user = await FireStoreUtils.getCurrentUser(userCredential.user?.uid ?? '');
          if (user != null) {
            hideProgress();
            MyAppState.currentUser = user;
            pushAndRemoveUntil(context, ContainerScreen(), false);
          } else if (user == null) {
            /// create a new user from phone login
            String profileImageUrl = '';
            String carPicUrl = DEFAULT_CAR_IMAGE;
            if (_image != null) {
              profileImageUrl = await FireStoreUtils.uploadUserImageToFireStorage(_image!, userCredential.user?.uid ?? '');
            }
            if (_carImage != null) {
              updateProgress('Uploading car image, Please wait...'.tr());
              carPicUrl = await FireStoreUtils.uploadCarImageToFireStorage(_carImage!, userCredential.user?.uid ?? '');
            }
            User user = User(
              firstName: _firstNameController.text,
              lastName: _firstNameController.text,
              fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
              phoneNumber: phoneNumber,
              isActive: true,
              lastOnlineTimestamp: Timestamp.now(),
              settings: UserSettings(),
              email: '',
              active: true,
              profilePictureURL: profileImageUrl,
              userID: userCredential.user?.uid ?? '',
              carPictureURL: carPicUrl,
              carNumber: carPlate!,
              carName: carName!,
              role: USER_ROLE_DRIVER,
              createdAt: Timestamp.now(),
            );
            String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
            hideProgress();
            if (errorMessage == null) {
              MyAppState.currentUser = user;
              pushAndRemoveUntil(context, ContainerScreen(), false);
            } else {
              showAlertDialog(context, 'Failed'.tr(), "notCreatePhoneNumber".tr(), true);
            }
          }
        }
      },
    );
  }
}
