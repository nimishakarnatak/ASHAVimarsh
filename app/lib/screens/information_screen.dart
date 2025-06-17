import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/category_card.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategories(),
          _buildEmergencySection(),
        ],
      ),
    );
  }

  // PDF Popup Method - Alternative approach without WebView
  void _showPdfPopup(BuildContext context, Map<String, dynamic> category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: category['color'],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${category['title']} Guide',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PDF Preview Icon
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: category['color'],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Description
                        Text(
                          'Comprehensive ${category['title']} Guide',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Content Items
                        Text(
                          'This guide includes detailed information about:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Items list
                        ...category['items'].map<Widget>((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: category['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        
                        const Spacer(),
                        
                        // File info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'PDF Document • ${category['totalItems']} pages',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Primary action - Open PDF
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openPdf(category['pdfUrl']),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: category['color'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Secondary actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _downloadPdf(category['pdfUrl']),
                              icon: const Icon(Icons.download),
                              label: const Text('Download'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: category['color'],
                                side: BorderSide(color: category['color']),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _sharePdf(category['pdfUrl'], category['title']),
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Open PDF in external viewer or browser
  Future<void> _openPdf(String pdfUrl) async {
    final Uri url = Uri.parse(pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens in external PDF viewer
      );
    } else {
      // Fallback: try opening in browser
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
      );
    }
  }

  // Download PDF functionality
  void _downloadPdf(String pdfUrl) async {
    // TODO: Implement PDF download functionality
    // You can use packages like:
    // - dio for downloading
    // - path_provider for getting storage path
    // - permission_handler for storage permissions
    
    print('Downloading PDF from: $pdfUrl');
    // Example implementation:
    /*
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/downloaded_pdf.pdf';
      
      await dio.download(pdfUrl, filePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF downloaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
    */
  }

  // Share PDF functionality
  void _sharePdf(String pdfUrl, String title) async {
    // TODO: Implement PDF sharing functionality
    // You can use the share_plus package
    
    print('Sharing PDF: $title - $pdfUrl');
    // Example implementation:
    /*
    await Share.share(
      'Check out this helpful guide: $title\n\n$pdfUrl',
      subject: title,
    );
    */
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: AppTextStyles.categoryTitle,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200, // Fixed height for the horizontal scroll view
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categoryData.length,
              padding: const EdgeInsets.only(right: 16),
              itemBuilder: (context, index) {
                final category = _categoryData[index];
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 160, // Fixed width for each card
                  child: CategoryCard(
                    title: category['title'],
                    items: category['items'],
                    color: category['color'],
                    totalItems: category['totalItems'],
                    onViewAllPressed: () => _showPdfPopup(context, category),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Category data list
  static final List<Map<String, dynamic>> _categoryData = [
    {
      'title': 'Maternal Help',
      'items': [
        'Postnatal Care',
        'Breastfeeding',
        'Maternal Nutrition',
      ],
      'color': AppColors.primary,
      'totalItems': 15,
      'pdfUrl': 'https://example.com/pdfs/maternal-help-guide.pdf',
    },
    {
      'title': 'Prenatal Health',
      'items': [
        'Prenatal Visits',
        'Nutrition Guidelines',
        'Risk Identification',
      ],
      'color': const Color(0xFF5BCCA8),
      'totalItems': 12,
      'pdfUrl': 'https://example.com/pdfs/prenatal-health-guide.pdf',
    },
    {
      'title': 'Child Care',
      'items': [
        'Vaccination Schedule',
        'Growth Monitoring',
        'Developmental Milestones',
      ],
      'color': const Color(0xFF4FC3F7),
      'totalItems': 18,
      'pdfUrl': 'https://example.com/pdfs/child-care-guide.pdf',
    },
    {
      'title': 'Mental Health',
      'items': [
        'Postpartum Depression',
        'Anxiety Management',
        'Stress Relief',
      ],
      'color': const Color(0xFF9575CD),
      'totalItems': 10,
      'pdfUrl': 'https://example.com/pdfs/mental-health-guide.pdf',
    },
    {
      'title': 'Family Planning',
      'items': [
        'Contraception Methods',
        'Fertility Awareness',
        'Pregnancy Planning',
      ],
      'color': const Color(0xFF81C784),
      'totalItems': 8,
      'pdfUrl': 'https://example.com/pdfs/family-planning-guide.pdf',
    },
    {
      'title': 'Nutrition Guide',
      'items': [
        'Healthy Recipes',
        'Dietary Guidelines',
        'Supplement Info',
      ],
      'color': const Color(0xFFFFB74D),
      'totalItems': 14,
      'pdfUrl': 'https://example.com/pdfs/nutrition-guide.pdf',
    },
    {
      'title': 'Exercise & Wellness',
      'items': [
        'Prenatal Exercises',
        'Postnatal Fitness',
        'Yoga & Meditation',
      ],
      'color': const Color(0xFFE57373),
      'totalItems': 11,
      'pdfUrl': 'https://example.com/pdfs/exercise-wellness-guide.pdf',
    },
    {
      'title': 'Medical Resources',
      'items': [
        'Hospital Directory',
        'Doctor Contacts',
        'Lab Test Info',
      ],
      'color': const Color(0xFF64B5F6),
      'totalItems': 20,
      'pdfUrl': 'https://example.com/pdfs/medical-resources-guide.pdf',
    },
  ];

  Widget _buildEmergencySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Information',
            style: AppTextStyles.categoryTitle,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.red),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: AppColors.red,
                  child: const Text(
                    'Emergency Cases',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildEmergencyItem('Bleeding During Pregnancy', true),
                _buildEmergencyItem('High Fever in Children', false),
                _buildEmergencyItem('Severe Abdominal Pain', false),
                _buildEmergencyItem('Difficulty Breathing', false),
                _buildEmergencyItem('Loss of Consciousness', false),
                Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9698),
                        border: Border.all(color: AppColors.red),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        'View All (15)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.red),
        color: isActive ? AppColors.red : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/arrow_icon.png',
            width: 18,
            height: 17,
          ),
        ],
      ),
    );
  }
}