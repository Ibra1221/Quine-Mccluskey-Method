import 'package:flutter/material.dart';
import 'package:quine_mccluskey_calculator/result.dart';

void main() {
  runApp(RestartWidget(child: MyApp()));
}

class QuineMcCluskey {
  final int number;
  final List<int> minTerms;
  final List<int> dontCares;

  QuineMcCluskey(this.number, this.minTerms, this.dontCares);

  static const String alphabet =
      'a b c d e f g h i j k l m n o p q r s t u v w x y z';
  static final List<String> capitalAlphabet = alphabet.toUpperCase().split(" ");
  static final List<String> capitalAlphabetDash = capitalAlphabet
      .map((letter) => "$letter'")
      .toList();

  String decimalToBinary(int decimal) => decimal.toRadixString(2);

  void padding(List<String> arr, int number) {
    for (int i = 0; i < arr.length; i++) {
      while (arr[i].length < number) {
        arr[i] = "0${arr[i]}";
      }
    }
  }

  int countOnes(String str) {
    return str.split("").where((c) => c == "1").length;
  }

  List<List<String>> groupingOnes(List<String> binMinTerms, int number) {
    List<List<String>> groups = List.generate(number + 1, (_) => []);
    for (String term in binMinTerms) {
      int numOfOnes = countOnes(term);
      if (!groups[numOfOnes].contains(term)) {
        groups[numOfOnes].add(term);
      }
    }
    return groups;
  }

  String getCompare(String str1, String str2) {
    if (str1.isEmpty || str2.isEmpty) return "";
    List<String> arr1 = str1.split("");
    List<String> arr2 = str2.split("");
    List<String> arr1Copy = List.from(arr1);
    int countChanges = 0;
    for (int i = 0; i < str1.length; i++) {
      if (arr1[i] != arr2[i]) {
        countChanges++;
        arr1Copy[i] = "_";
      }
    }
    return (countChanges == 1) ? arr1Copy.join("") : "";
  }

  Map<String, dynamic> checkPairs(List<List<String>> group) {
    List<String> allNewCombinedTerms = [];
    List<String> usedTerms = [];
    for (int i = 0; i < group.length - 1; i++) {
      if (group[i].isEmpty || group[i + 1].isEmpty) continue;
      for (String term1 in group[i]) {
        for (String term2 in group[i + 1]) {
          String combined = getCompare(term1, term2);
          if (combined.isNotEmpty) {
            if (!allNewCombinedTerms.contains(combined)) {
              allNewCombinedTerms.add(combined);
            }
            if (!usedTerms.contains(term1)) usedTerms.add(term1);
            if (!usedTerms.contains(term2)) usedTerms.add(term2);
          }
        }
      }
    }
    List<List<String>> newGroup = groupingOnes(allNewCombinedTerms, number);
    return {"newGroup": newGroup, "usedTerms": usedTerms};
  }

  String letterExtraction(String bit, int index) {
    switch (bit) {
      case '1':
        return capitalAlphabet[index];
      case '0':
        return capitalAlphabetDash[index];
      case '_':
        return '';
      default:
        return '';
    }
  }

  String getPI(List<String> newGroup, int number) {
    List<String> piStrings = [];
    for (String term in newGroup) {
      String termString = "";
      for (int k = 0; k < number; k++) {
        termString += letterExtraction(term[k], k);
      }
      piStrings.add(termString);
    }
    return piStrings.join(', ');
  }

  bool isCoveredBy(String minterm, String implicant) {
    for (int i = 0; i < implicant.length; i++) {
      if (implicant[i] != '_' && implicant[i] != minterm[i]) {
        return false;
      }
    }
    return true;
  }

  String getEPI(List<String> primeImplicants, List<String> binMinTerms) {
    List<String> essentialPIs = [];
    List<String> solutionPIs = [];
    List<int> mintermsToCover = List.from(minTerms);

    for (int i = 0; i < minTerms.length; i++) {
      String minterm = binMinTerms[i];
      List<String> coveringPIs = [];
      for (String pi in primeImplicants) {
        if (isCoveredBy(minterm, pi)) coveringPIs.add(pi);
      }
      if (coveringPIs.length == 1 && !essentialPIs.contains(coveringPIs[0])) {
        essentialPIs.add(coveringPIs[0]);
      }
    }

    solutionPIs.addAll(essentialPIs);

    List<int> coveredByEssentials = [];
    for (String epi in essentialPIs) {
      for (int j = 0; j < minTerms.length; j++) {
        if (isCoveredBy(binMinTerms[j], epi) &&
            !coveredByEssentials.contains(minTerms[j])) {
          coveredByEssentials.add(minTerms[j]);
        }
      }
    }

    mintermsToCover.removeWhere((mt) => coveredByEssentials.contains(mt));

    while (mintermsToCover.isNotEmpty) {
      String? bestPi;
      int maxCovered = 0;
      for (String pi in primeImplicants) {
        if (solutionPIs.contains(pi)) continue;
        int coveredCount = 0;
        for (int j = 0; j < minTerms.length; j++) {
          if (mintermsToCover.contains(minTerms[j]) &&
              isCoveredBy(binMinTerms[j], pi)) {
            coveredCount++;
          }
        }
        if (coveredCount > maxCovered) {
          maxCovered = coveredCount;
          bestPi = pi;
        }
      }
      if (bestPi != null) {
        solutionPIs.add(bestPi);
        List<int> newlyCovered = [];
        for (int j = 0; j < minTerms.length; j++) {
          if (isCoveredBy(binMinTerms[j], bestPi)) {
            newlyCovered.add(minTerms[j]);
          }
        }
        mintermsToCover.removeWhere((mt) => newlyCovered.contains(mt));
      } else {
        break;
      }
    }

    List<String> finalExpression = [];
    for (String pi in solutionPIs) {
      String termString = "";
      for (int k = 0; k < number; k++) {
        termString += letterExtraction(pi[k], k);
      }
      finalExpression.add(termString);
    }

    return finalExpression.join(" + ");
  }

  /// Main execution
  Map<String, String> run() {
    // Add debug prints
    print("Input values:");
    print("Number of variables: $number");
    print("Minterms: $minTerms");
    print("Don't cares: $dontCares");

    List<String> binMinTerms = minTerms
        .map((mt) => decimalToBinary(mt))
        .toList();
    List<String> binDontCares = dontCares
        .map((dc) => decimalToBinary(dc))
        .toList();

    print("Binary minterms: $binMinTerms");
    print("Binary don't cares: $binDontCares");

    padding(binMinTerms, number);
    padding(binDontCares, number);

    List<String> totalMinterms = [...binMinTerms, ...binDontCares];
    print("Total minterms after padding: $totalMinterms");

    List<String> primeImplicants = [];
    List<List<String>> group = groupingOnes(totalMinterms, number);
    print("Initial grouping: $group");

    while (true) {
      List<String> allCurrentTerms = group.expand((e) => e).toList();
      var returned = checkPairs(group);
      List<List<String>> nextGroup = returned["newGroup"];
      List<String> usedTerms = returned["usedTerms"];
      List<String> allNewTerms = nextGroup.expand((e) => e).toList();

      for (String term in allCurrentTerms) {
        if (!usedTerms.contains(term) && !primeImplicants.contains(term)) {
          primeImplicants.add(term);
        }
      }

      if (group.toString() == nextGroup.toString()) {
        break;
      }
      group = nextGroup;
    }

    String finalExpression = getEPI(primeImplicants, binMinTerms);
    print("Final Expression: $finalExpression");

    return {
      "Prime Implicants": primeImplicants.isEmpty
          ? "No prime implicants found"
          : getPI(primeImplicants, number),
      "Final Expression": finalExpression.isEmpty
          ? "F = 0"
          : "F = $finalExpression",
    };
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  var _formKey = GlobalKey<FormState>();

  int? _submit() {
    // Validate the form fields
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // If the form is not valid, return without doing anything
      return null;
    }
    // Save the form state
    _formKey.currentState!.save();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Quine Mccluskey Method Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int number = 0;
  List<int> minTerms = [];
  List<int> dontCares = [];

  final _formKey = GlobalKey<FormState>();
  
  // Add TextEditingControllers
  final _numberController = TextEditingController();
  final _mintermsController = TextEditingController();
  final _dontCaresController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers
    _numberController.dispose();
    _mintermsController.dispose();
    _dontCaresController.dispose();
    super.dispose();
  }

  int? _submit() {
    // Validate the form fields
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return null;
    }
    
    // Parse and assign values after validation passes
    try {
      number = int.parse(_numberController.text.trim());
      
      String mintermsText = _mintermsController.text.trim();
      if (mintermsText.isNotEmpty) {
        minTerms = mintermsText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) => int.parse(e))
            .toList();
      } else {
        minTerms = [];
      }
      
      String dontCaresText = _dontCaresController.text.trim();
      if (dontCaresText.isNotEmpty) {
        dontCares = dontCaresText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) => int.parse(e))
            .toList();
      } else {
        dontCares = [];
      }
      
      return 0;
    } catch (e) {
      print('Error parsing values: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Enter the number of variables:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextFormField(
                            controller: _numberController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: 'e.g., 4',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter a number";
                              }
                              
                              int? parsedValue = int.tryParse(value.trim());
                              if (parsedValue == null || parsedValue <= 0) {
                                return "Please enter a valid positive number";
                              }
                              
                              return null; // Valid
                            },
                          ),
                          SizedBox(height: 20),
                          
                          const Text(
                            "Enter the minterms:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextFormField(
                            controller: _mintermsController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: 'e.g., 1,2,3,4',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter at least one minterm";
                              }
                              
                              try {
                                // Get current number value for validation
                                int currentNumber = int.tryParse(_numberController.text.trim()) ?? 0;
                                if (currentNumber <= 0) {
                                  return "Please enter number of variables first";
                                }
                                
                                List<int> testMinTerms = value
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .map((e) => int.parse(e))
                                    .toList();

                                if (testMinTerms.isEmpty) {
                                  return "Please enter valid minterms";
                                }

                                if (testMinTerms.any((mt) => mt < 0 || mt >= (1 << currentNumber))) {
                                  return "Minterms must be between 0 and ${(1 << currentNumber) - 1}";
                                }
                                
                                return null; // Valid
                              } catch (e) {
                                return "Please enter valid numbers separated by commas";
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          
                          const Text(
                            "Enter the Don't Cares (Optional):",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextFormField(
                            controller: _dontCaresController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: 'e.g., 5,6 (optional)',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null; // Optional field
                              }
                              
                              try {
                                // Get current number value for validation
                                int currentNumber = int.tryParse(_numberController.text.trim()) ?? 0;
                                if (currentNumber <= 0) {
                                  return "Please enter number of variables first";
                                }
                                
                                List<int> testDontCares = value
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .map((e) => int.parse(e))
                                    .toList();

                                if (testDontCares.any((dc) => dc < 0 || dc >= (1 << currentNumber))) {
                                  return "Don't cares must be between 0 and ${(1 << currentNumber) - 1}";
                                }
                                
                                return null; // Valid
                              } catch (e) {
                                return "Please enter valid numbers separated by commas";
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_submit() != null) {
                    print("Processing input:");
                    print("Number of variables: $number");
                    print("Minterms: $minTerms");
                    print("Don't cares: $dontCares");

                    QuineMcCluskey qm = QuineMcCluskey(
                      number,
                      minTerms,
                      dontCares,
                    );

                    final result = qm.run();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ResultPage(result: result),
                        transitionDuration: Duration(milliseconds: 500),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
                child: Text("Get Result"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}