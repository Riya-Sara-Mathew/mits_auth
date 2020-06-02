import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth_device_credentials/local_auth.dart';
import 'homepage.dart';
import 'phno.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'MITS staff Attendance',
      routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) => MyHome(),
        '/loginpage': (BuildContext context) => MyApp(),
        '/firstpage': (BuildContext context) => LoginPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyApps(title: 'MITS staff Attendance')
     
    );
    
  }
}
class MyApps extends StatefulWidget {  
  MyApps({Key key, this.title}) : super(key: key);  
  final String title;  
  
  @override  
  _MyAppsState createState() => _MyAppsState();  
}  
  
class _MyAppsState extends State<MyApps> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool _isSupported;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then((isSupported) =>
        setState(() => _isSupported = isSupported));
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      setState(() =>
      _authorized = authenticated ? 'Authorized' : 'Not Authorized');
      authenticated
          ? Navigator.of(context).pushReplacementNamed('/firstpage')
          : Navigator.of(context).pushReplacementNamed('/loginpage');
    } on PlatformException catch (e) {
      setState(() => _authorized = e.message);
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
        authenticated
            ? Navigator.of(context).pushReplacementNamed('/firstpage')
            : Navigator.of(context).pushReplacementNamed('/loginpage');
      });
    } on PlatformException catch (e) {
      setState(() => _authorized = e.message);
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  void _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text("Has FingerPrint Support : $_hasFingerPrintSupport"),
            // Text(
            //  "List of Biometrics Support: ${_availableBuimetricType.toString()}"),
            //  Text("Authorized : $_authorizedOrNot"),
            RaisedButton(
              child: Text("Verify it's you"),
              textColor: Colors.white,
              elevation: 10,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              color: Colors.red,
              onPressed: () async {
                if (_isSupported) {
                  _authenticate();
                }
                else
                  Text("This device is not supported");
              },
            ),
          ],
        ),
      ),
    );
  }
}