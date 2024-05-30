import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AppGlobal.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/User.dart';
import 'package:flutter_application_1/services/FirebaseHelper.dart';
import 'package:flutter_application_1/services/helper.dart';
import 'package:flutter_application_1/ui/reauthScreen/reauth_user_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AccountDetailsScreen extends StatefulWidget {
  final User user;

  AccountDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late User user;
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;

    setState(() {
      firstName.text = MyAppState.currentUser!.firstName;
      lastName.text = MyAppState.currentUser!.lastName;
      email.text = MyAppState.currentUser!.email;
      mobile.text = MyAppState.currentUser!.phoneNumber;
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppGlobal.buildSimpleAppBar(context, "Account Details".tr()),
          body: SingleChildScrollView(
            child: Form(
              key: _key,
              autovalidateMode: _validate,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                  child: Text(
                    "PUBLIC INFO",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ).tr(),
                ),
                Material(
                    elevation: 2,
                    color: isDarkMode(context) ? Colors.black12 : Colors.white,
                    child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: ListTile.divideTiles(context: context, tiles: [
                          ListTile(
                            title: Text(
                              'First Name'.tr(),
                              style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              ),
                            ).tr(),
                            trailing: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: TextFormField(
                                controller: firstName,
                                validator: validateName,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                cursorColor: const Color(COLOR_ACCENT),
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(border: InputBorder.none, hintText: 'First Name'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Last Name'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                            ).tr(),
                            trailing: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: TextFormField(
                                controller: lastName,
                                validator: validateName,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                cursorColor: const Color(COLOR_ACCENT),
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(border: InputBorder.none, hintText: 'Last Name'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                              ),
                            ),
                          ),
                        ]).toList())),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                  child: Text(
                    'PRIVATE DETAILS',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ).tr(),
                ),
                Material(
                  elevation: 2,
                  color: isDarkMode(context) ? Colors.black12 : Colors.white,
                  child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          ListTile(
                            title: Text(
                              'Email Address'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                            ).tr(),
                            trailing: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: TextFormField(
                                controller: email,
                                validator: validateEmail,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                cursorColor: const Color(COLOR_ACCENT),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(border: InputBorder.none, hintText: 'Email Address'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Phone Number'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                            ).tr(),
                            trailing: InkWell(
                              onTap: () {
                                showAlertDialog(context);
                              },
                              child: Text(MyAppState.currentUser!.phoneNumber),
                            ),
                          ),
                        ],
                      ).toList()),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      child: Material(
                        elevation: 2,
                        color: isDarkMode(context) ? Colors.black12 : Colors.white,
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(12.0),
                          onPressed: () async {
                            _validateAndSave();
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY)),
                          ).tr(),
                        ),
                      ),
                    )),
              ]),
            ),
          )),
    );
  }

  bool _isPhoneValid = false;
  String? _phoneNumber = "";

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel").tr(),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue").tr(),
      onPressed: () {
        if (_isPhoneValid) {
          setState(() {
            MyAppState.currentUser!.phoneNumber = _phoneNumber.toString();
            mobile.text = _phoneNumber.toString();
          });
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Change Phone Number").tr(),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), shape: BoxShape.rectangle, border: Border.all(color: Colors.grey.shade200)),
        child: InternationalPhoneNumberInput(
          onInputChanged: (value) {
            _phoneNumber = "${value.phoneNumber}";
          },
          onInputValidated: (bool value) => _isPhoneValid = value,
          ignoreBlank: true,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            hintText: 'Phone Number'.tr(),
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            isDense: true,
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          inputBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          initialValue: PhoneNumber(isoCode: 'US'),
          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  _validateAndSave() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      AuthProviders? authProvider;
      List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
      await Future.forEach(userInfoList, (auth.UserInfo info) {
        if (info.providerId == 'password') {
          authProvider = AuthProviders.PASSWORD;
        } else if (info.providerId == 'phone') {
          authProvider = AuthProviders.PHONE;
        }
      });
      bool? result = false;
      if (authProvider == AuthProviders.PHONE && auth.FirebaseAuth.instance.currentUser!.phoneNumber != mobile.text) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            phoneNumber: mobile.text,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, "Saving details...".tr(), false);
          await _updateUser();
          await hideProgress();
        }
      } else if (authProvider == AuthProviders.PASSWORD && auth.FirebaseAuth.instance.currentUser!.email != email.text) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            email: email.text,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, 'Saving details...'.tr(), false);
          await _updateUser();
          await hideProgress();
        }
      } else {
        showProgress(context, 'Saving details...'.tr(), false);
        await _updateUser();
        hideProgress();
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateUser() async {
    user.firstName = firstName.text;
    user.lastName = lastName.text;
    user.email = email.text;
    user.phoneNumber = mobile.text;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Details saved successfully",
        style: TextStyle(fontSize: 17),
      ).tr()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Couldn't save details, Please try again.",
        style: TextStyle(fontSize: 17),
      ).tr()));
    }
  }
}
