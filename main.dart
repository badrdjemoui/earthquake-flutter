// استيراد مكتبة Flutter الأساسية لبناء الواجهة
import 'package:flutter/material.dart';

// استيراد الخدمة التي تجلب بيانات الزلازل من الإنترنت
import 'services/api_service.dart';

// استيراد النموذج (model) الذي يمثل الزلزال
import 'models/earthquake.dart';

// مكتبة خارجية لتنسيق التاريخ والوقت بشكل جميل
import 'package:intl/intl.dart';

// دالة البداية الرئيسية للتطبيق
void main() {
  runApp(EarthquakeApp());
}

// هذا هو التطبيق الرئيسي الذي يحتوي على التصميم العام (MaterialApp)
class EarthquakeApp extends StatelessWidget {
  const EarthquakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // لإخفاء شعار "debug" من التطبيق
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // تعيين اللون الرئيسي للتطبيق
        scaffoldBackgroundColor: Colors.grey[100], // لون الخلفية
      ),
      home: EarthquakeScreen(), // الشاشة الرئيسية التي ستُعرض
    );
  }
}

// شاشة الزلازل الرئيسية وهي Stateful لأنها تحتوي على بيانات متغيرة
class EarthquakeScreen extends StatefulWidget {
  const EarthquakeScreen({super.key});

  @override
  _EarthquakeScreenState createState() => _EarthquakeScreenState();
}

// الحالة الخاصة بشاشة الزلازل
class _EarthquakeScreenState extends State<EarthquakeScreen> {
  late Future<List<Earthquake>> futureEarthquakes; // متغيّر لحفظ بيانات الزلازل المستقبلية

  @override
  void initState() {
    super.initState();
    fetchData(); // جلب البيانات عند بداية تشغيل الشاشة
  }

  // دالة تقوم بجلب البيانات من الإنترنت باستخدام الـ API
  void fetchData() {
    futureEarthquakes = ApiService.fetchEarthquakes();
  }

  // دالة لتنسيق الوقت إلى شكل مناسب مثل: Jan 12, 2025 - 8:45 PM
  String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Earthquakes"), // عنوان التطبيق
        centerTitle: true, // لجعل العنوان في الوسط
      ),

      // FutureBuilder يسمح ببناء الواجهة حسب حالة البيانات: تحميل، خطأ، أو جاهزة
      body: FutureBuilder<List<Earthquake>>(
        future: futureEarthquakes, // البيانات القادمة من الإنترنت
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // أثناء تحميل البيانات
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // في حال وجود خطأ أثناء جلب البيانات
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // في حال لم يتم العثور على بيانات
            return Center(child: Text("No earthquakes found."));
          } else {
            // عند وجود بيانات جاهزة للعرض
            return RefreshIndicator(
              onRefresh: () async {
                // عند السحب لتحديث البيانات
                setState(() {
                  fetchData(); // إعادة تحميل البيانات
                });
              },
              child: ListView.builder(
                padding: EdgeInsets.all(8), // مسافة بين الحواف والعناصر
                itemCount: snapshot.data!.length, // عدد الزلازل
                itemBuilder: (context, index) {
                  final earthquake = snapshot.data![index]; // عنصر الزلزال الحالي

                  // تحديد لون حسب شدة الزلزال
                  Color magnitudeColor = earthquake.magnitude >= 5
                      ? Colors.red // قوي
                      : earthquake.magnitude >= 3
                          ? Colors.orange // متوسط
                          : Colors.green; // ضعيف

                  // تصميم كل عنصر باستخدام Card (بطاقة)
                  return Card(
                    elevation: 4, // ارتفاع الظل
                    margin: EdgeInsets.symmetric(vertical: 6), // مسافة بين العناصر
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // حواف دائرية
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: magnitudeColor, // لون حسب القوة
                        child: Text(
                          earthquake.magnitude.toStringAsFixed(1), // عرض القوة
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(earthquake.place), // اسم المكان
                      subtitle: Text("Time: ${formatTime(earthquake.time)}"), // الوقت المنسق
                      trailing: Icon(Icons.arrow_forward_ios, size: 16), // أيقونة على اليمين
                      onTap: () {
                        // مكان لإضافة شاشة التفاصيل لاحقًا
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
