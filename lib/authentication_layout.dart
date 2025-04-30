import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';

import 'constants.dart';

class AuthenticationLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final String mainButtonTitle;
  final Widget form;
  final bool showTermsText;
  final void Function()? onMainButtonTapped;
  final void Function()? onCreateAccountTapped;
  final void Function()? onForgotPassword;
  final void Function()? onBackPressed;
  final void Function()? onSignInWithApple;
  final void Function()? onSignInWithGoogle;
  final String? validationMessage;
  final bool busy;

  const AuthenticationLayout({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.mainButtonTitle,
    required this.form,
    this.onMainButtonTapped,
    this.onCreateAccountTapped,
    this.onForgotPassword,
    this.onBackPressed,
    this.onSignInWithApple,
    this.onSignInWithGoogle,
    this.validationMessage,
    this.showTermsText = false,
    this.busy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView(
        children: [
          if (onBackPressed == null) verticalSpaceLarge,
          if (onBackPressed != null) verticalSpaceRegular,
          if (onBackPressed != null)
            IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: onBackPressed,
            ),
          Text(
            title,
            style: const TextStyle(fontSize: 34),
          ),
          verticalSpaceSmall,
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: screenWidthPercentage(context, percentage: 0.7),
              child: Text(
                subtitle,
                style: bodyStyle.copyWith(color: Colors.grey.shade400),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          verticalSpaceRegular,
          form,
          verticalSpaceRegular,
          if (onForgotPassword != null)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: onForgotPassword,
                  child: Text(
                    'Forget Password?',
                    style: bodyStyle.copyWith(color: kcMediumGreyColor),
                    textAlign: TextAlign.start,
                  )),
            ),
          verticalSpaceRegular,
          if (validationMessage != null)
            Text(
              validationMessage!,
              style: bodyStyle.copyWith(color: Colors.red,),
              textAlign: TextAlign.center
            ),
          if (validationMessage != null) verticalSpaceRegular,
          GestureDetector(
            onTap: onMainButtonTapped,
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kcPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: busy
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : Text(
                      mainButtonTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
            ),
          ),
          verticalSpaceRegular,
          if (onCreateAccountTapped != null)
            GestureDetector(
              onTap: onCreateAccountTapped,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?'),
                  horizontalSpaceTiny,
                  Text(
                    'Create an account',
                    style: TextStyle(
                      color: kcPrimaryColor,
                    ),
                  )
                ],
              ),
            ),
          if (showTermsText)
            Text(
              'By signing up you agree to our terms, conditions and privacy policy.',
              style: bodyStyle.copyWith(color: kcMediumGreyColor),
              textAlign: TextAlign.start
            ),
          verticalSpaceRegular,
          Align(
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                const Expanded(child: Divider()),       
                Text(
                  ' OR ',
                  style: bodyStyle.copyWith(color: kcMediumGreyColor),
                  textAlign: TextAlign.start
                ),        
                const Expanded(child: Divider()),
              ]
            )
          ),
          verticalSpaceRegular,
          AppleAuthButton(
            onPressed: onSignInWithApple ?? () {},
            // darkMode: true,
            text: 'CONTINUE WITH APPLE',
            style: const AuthButtonStyle(
              buttonType: AuthButtonType.secondary,
              height: 50,
              separator: 30,
              textStyle: TextStyle(color: Colors.white),
            ),
          ),
          verticalSpaceRegular,
          GoogleAuthButton(
            onPressed: onSignInWithGoogle ?? () {},
            text: 'CONTINUE WITH GOOGLE',
            style: const AuthButtonStyle(
              buttonColor: Color(0xff4285F4),
              buttonType: AuthButtonType.secondary,
              height: 50,
              separator: 20,
              iconBackground: Colors.white,
              textStyle: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}