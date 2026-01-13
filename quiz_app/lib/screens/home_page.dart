import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/navigation_provider.dart';
import 'package:quiz_app/utils/color.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _userName = '';
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Mock course data - In production, this would come from Firebase
  final List<Map<String, dynamic>> _featuredCourses = [
    {
      'id': '1',
      'title': 'Master Python Programming',
      'instructor': 'Dr. Sarah Chen',
      'rating': 4.8,
      'students': 12453,
      'image': 'python',
      'color': Color(0xFF3776AB),
      'category': 'Programming',
      'duration': '24h 30m',
      'lessons': 85,
    },
    {
      'id': '2',
      'title': 'Advanced Mathematics',
      'instructor': 'Prof. James Wilson',
      'rating': 4.9,
      'students': 8921,
      'image': 'math',
      'color': Color(0xFF6B5B95),
      'category': 'Mathematics',
      'duration': '18h 45m',
      'lessons': 62,
    },
    {
      'id': '3',
      'title': 'Complete Biology Course',
      'instructor': 'Dr. Emma Roberts',
      'rating': 4.7,
      'students': 6234,
      'image': 'biology',
      'color': Color(0xFF88B04B),
      'category': 'Science',
      'duration': '21h 15m',
      'lessons': 73,
    },
  ];

  final List<Map<String, dynamic>> _allCourses = [
    {
      'id': '4',
      'title': 'JavaScript Fundamentals',
      'instructor': 'Mike Johnson',
      'rating': 4.6,
      'students': 15678,
      'color': Color(0xFFF7DF1E),
      'category': 'Programming',
      'duration': '16h 20m',
      'lessons': 54,
      'isBestseller': true,
    },
    {
      'id': '5',
      'title': 'World History: Ancient to Modern',
      'instructor': 'Prof. David Lee',
      'rating': 4.8,
      'students': 4521,
      'color': Color(0xFF8B4513),
      'category': 'History',
      'duration': '28h 10m',
      'lessons': 96,
      'isBestseller': false,
    },
    {
      'id': '6',
      'title': 'Chemistry Essentials',
      'instructor': 'Dr. Lisa Wang',
      'rating': 4.5,
      'students': 7890,
      'color': Color(0xFF00CED1),
      'category': 'Science',
      'duration': '19h 45m',
      'lessons': 68,
      'isBestseller': true,
    },
    {
      'id': '7',
      'title': 'English Literature Masterclass',
      'instructor': 'Prof. Margaret Smith',
      'rating': 4.7,
      'students': 3456,
      'color': Color(0xFFDC143C),
      'category': 'Language',
      'duration': '22h 30m',
      'lessons': 78,
      'isBestseller': false,
    },
    {
      'id': '8',
      'title': 'Physics: From Basics to Advanced',
      'instructor': 'Dr. Robert Brown',
      'rating': 4.9,
      'students': 9234,
      'color': Color(0xFF4169E1),
      'category': 'Science',
      'duration': '32h 15m',
      'lessons': 110,
      'isBestseller': true,
    },
    {
      'id': '9',
      'title': 'Data Science & Analytics',
      'instructor': 'Sarah Mitchell',
      'rating': 4.8,
      'students': 11234,
      'color': Color(0xFF9370DB),
      'category': 'Programming',
      'duration': '26h 45m',
      'lessons': 89,
      'isBestseller': true,
    },
    {
      'id': '10',
      'title': 'Art History & Appreciation',
      'instructor': 'Prof. Claire Martin',
      'rating': 4.6,
      'students': 2345,
      'color': Color(0xFFFF6347),
      'category': 'Arts',
      'duration': '15h 20m',
      'lessons': 52,
      'isBestseller': false,
    },
    {
      'id': '11',
      'title': 'Economics: Micro & Macro',
      'instructor': 'Dr. Alan Peterson',
      'rating': 4.7,
      'students': 5678,
      'color': Color(0xFF2E8B57),
      'category': 'Business',
      'duration': '20h 30m',
      'lessons': 70,
      'isBestseller': false,
    },
    {
      'id': '12',
      'title': 'Psychology Fundamentals',
      'instructor': 'Dr. Nicole Adams',
      'rating': 4.8,
      'students': 8901,
      'color': Color(0xFFDA70D6),
      'category': 'Science',
      'duration': '17h 45m',
      'lessons': 60,
      'isBestseller': true,
    },
  ];

  final List<String> _categories = [
    'All',
    'Programming',
    'Science',
    'Mathematics',
    'Language',
    'History',
    'Arts',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!mounted) return;
        if (doc.exists) {
          setState(() {
            _userName = doc.data()?['name'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _allCourses.where((course) {
      final matchesCategory =
          _selectedCategory == 'All' || course['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          course['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course['instructor'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar with Search
            SliverToBoxAdapter(child: _buildHeader()),

            // Featured Courses Hero Section
            SliverToBoxAdapter(child: _buildFeaturedSection()),

            // Category Filter Chips
            SliverToBoxAdapter(child: _buildCategoryChips()),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Courses',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_filteredCourses.length} courses',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Course Grid
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                100 + MediaQuery.of(context).padding.bottom,
              ),
              sliver: _filteredCourses.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildCourseCard(_filteredCourses[index]);
                      }, childCount: _filteredCourses.length),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Profile Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userName.isNotEmpty ? _userName : 'Learner',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ref.read(bottomNavIndexProvider.notifier).setIndex(3);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'L',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search courses, topics, or instructors...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Courses',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to see all featured courses
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _featuredCourses.length,
            itemBuilder: (context, index) {
              return _buildFeaturedCard(_featuredCourses[index], index);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> course, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to course detail
        _showCourseDetails(course);
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(
          right: index < _featuredCourses.length - 1 ? 16 : 0,
        ),
        decoration: BoxDecoration(
          color: course['color'] as Color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (course['color'] as Color).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                _getCategoryIcon(course['category']),
                size: 150,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    course['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Instructor
                  Text(
                    course['instructor'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course['rating']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(course['students']),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
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
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(
                right: index < _categories.length - 1 ? 10 : 0,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final bool isBestseller = course['isBestseller'] ?? false;

    return GestureDetector(
      onTap: () {
        _showCourseDetails(course);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Course Thumbnail
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: course['color'] as Color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(course['category']),
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            // Course Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course['category'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (isBestseller) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBright.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Bestseller',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBright,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      course['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Instructor
                    Text(
                      course['instructor'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Stats Row
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course['rating']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_formatNumber(course['students'])})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course['duration'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No courses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter to find what you\'re looking for.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text(
              'Clear filters',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CourseDetailSheet(course: course),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Programming':
        return Icons.code_rounded;
      case 'Science':
        return Icons.science_rounded;
      case 'Mathematics':
        return Icons.calculate_rounded;
      case 'Language':
        return Icons.translate_rounded;
      case 'History':
        return Icons.history_edu_rounded;
      case 'Arts':
        return Icons.palette_rounded;
      case 'Business':
        return Icons.business_center_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Course Detail Bottom Sheet
class _CourseDetailSheet extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseDetailSheet({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Header
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: course['color'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            _getCategoryIcon(course['category']),
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  course['category'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                course['title'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructor Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          course['instructor']
                              .toString()
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['instructor'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Instructor',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        value: '${course['rating']}',
                        label: 'Rating',
                      ),
                      _buildStatItem(
                        icon: Icons.people_rounded,
                        iconColor: AppColors.primary,
                        value: _formatNumber(course['students']),
                        label: 'Students',
                      ),
                      _buildStatItem(
                        icon: Icons.play_circle_rounded,
                        iconColor: AppColors.accentBright,
                        value: '${course['lessons']}',
                        label: 'Lessons',
                      ),
                      _buildStatItem(
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.secondary,
                        value: course['duration'].toString().split(' ')[0],
                        label: 'Hours',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'About this course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Master the fundamentals and advanced concepts of ${course['title']}. '
                    'This comprehensive course is designed for learners who want to build '
                    'a solid foundation and develop practical skills. Learn from ${course['instructor']}, '
                    'an expert in the field with years of teaching experience.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to course or enroll
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Learning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 26, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Programming':
        return Icons.code_rounded;
      case 'Science':
        return Icons.science_rounded;
      case 'Mathematics':
        return Icons.calculate_rounded;
      case 'Language':
        return Icons.translate_rounded;
      case 'History':
        return Icons.history_edu_rounded;
      case 'Arts':
        return Icons.palette_rounded;
      case 'Business':
        return Icons.business_center_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
