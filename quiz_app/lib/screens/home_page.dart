import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/services/course_pack_service.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/providers/navigation_provider.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/translations.dart';

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
  bool _isLoadingCourses = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Dynamic course data from database
  List<CoursePack> _featuredCourses = [];
  List<CoursePack> _allCourses = [];
  String? _errorMessage;

  // Random colors for courses (consistent per course ID)
  static const List<Color> _courseColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6B7280), // Gray
    Color(0xFF84CC16), // Lime
  ];

  // Random icons for courses (consistent per course ID)
  static const List<IconData> _courseIcons = [
    Icons.school_rounded,
    Icons.auto_stories_rounded,
    Icons.psychology_rounded,
    Icons.lightbulb_rounded,
    Icons.extension_rounded,
    Icons.rocket_launch_rounded,
    Icons.insights_rounded,
    Icons.emoji_objects_rounded,
    Icons.workspace_premium_rounded,
    Icons.military_tech_rounded,
    Icons.stars_rounded,
    Icons.bolt_rounded,
    Icons.diamond_rounded,
    Icons.local_fire_department_rounded,
    Icons.explore_rounded,
    Icons.hub_rounded,
  ];

  // Get consistent random color for a course based on its ID
  Color _getRandomColor(String courseId) {
    final hash = courseId.hashCode.abs();
    return _courseColors[hash % _courseColors.length];
  }

  // Get consistent random icon for a course based on its ID
  IconData _getRandomIcon(String courseId) {
    final hash = courseId.hashCode.abs();
    return _courseIcons[hash % _courseIcons.length];
  }

  // Color mapping for categories (fallback)

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCourses();
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
      AppLogger.error('Error loading user data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoadingCourses = true;
        _errorMessage = null;
      });

      // Fetch featured courses (highest rated)
      final featured = await CoursePackService.fetchFeaturedCoursePacks(
        limit: 5,
      );

      // Fetch all public courses
      final all = await CoursePackService.fetchPublicCoursePacks(limit: 50);

      if (!mounted) return;
      setState(() {
        _featuredCourses = featured;
        _allCourses = all;
        _isLoadingCourses = false;
      });
    } catch (e) {
      AppLogger.error('Error loading courses: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load courses';
        _isLoadingCourses = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr(ref);
    if (hour < 17) return 'good_afternoon'.tr(ref);
    return 'good_evening'.tr(ref);
  }

  List<CoursePack> get _filteredCourses {
    return _allCourses.where((course) {
      final matchesCategory =
          _selectedCategory == 'All' || course.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(_searchQuery.toLowerCase());
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
        child: RefreshIndicator(
          onRefresh: _loadCourses,
          color: AppColors.primary,
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
                sliver: _isLoadingCourses
                    ? SliverToBoxAdapter(child: _buildLoadingState())
                    : _filteredCourses.isEmpty
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
                hintText: 'Search courses, topics...',
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
    if (_isLoadingCourses) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_featuredCourses.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  // Scroll to the All Courses section
                  _scrollController.animateTo(
                    600, // Approximate position of All Courses section
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
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

  Widget _buildFeaturedCard(CoursePack course, int index) {
    final color = _getRandomColor(course.id);
    final icon = _getRandomIcon(course.id);

    return GestureDetector(
      onTap: () {
        _showCourseDetails(course);
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(
          right: index < _featuredCourses.length - 1 ? 16 : 0,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
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
                icon,
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
                      course.category,
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
                    course.name,
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
                  // Stats
                  Text(
                    '${course.totalItems} items',
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
                        course.rating > 0
                            ? course.rating.toStringAsFixed(1)
                            : 'New',
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
                        _formatNumber(course.enrolledCount),
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
    // Get unique categories from courses
    final courseCategories = _allCourses.map((c) => c.category).toSet();
    final displayCategories = [
      'All',
      ...courseCategories.where((c) => c.isNotEmpty),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: displayCategories.length,
          itemBuilder: (context, index) {
            final category = displayCategories.elementAt(index);
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(
                right: index < displayCategories.length - 1 ? 10 : 0,
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

  Widget _buildCourseCard(CoursePack course) {
    final color = _getRandomColor(course.id);
    final icon = _getRandomIcon(course.id);
    final bool isBestseller = course.enrolledCount > 100;

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
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  icon,
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
                            course.category,
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
                              'Popular',
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
                      course.name,
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
                    // Stats
                    Text(
                      '${course.totalItems} items',
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
                          course.rating > 0
                              ? course.rating.toStringAsFixed(1)
                              : 'New',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_formatNumber(course.enrolledCount)})',
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
                          _formatDuration(course.estimatedHours),
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

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
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
              Icons.school_rounded,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'No courses available yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filter.'
                : 'Be the first to create and publish a course!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
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
        ],
      ),
    );
  }

  void _showCourseDetails(CoursePack course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CourseDetailSheet(
        course: course,
        currentUserId: _auth.currentUser?.uid,
        courseColor: _getRandomColor(course.id),
        courseIcon: _getRandomIcon(course.id),
        onClaim: () {
          // Refresh courses after claiming
          _loadCourses();
        },
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(double hours) {
    if (hours < 1) {
      // Convert to minutes and round to nearest 10
      final minutes = (hours * 60).round();
      final roundedMinutes = ((minutes / 10).round() * 10);
      return '${roundedMinutes}m';
    }
    // For 1 hour or more, show in hours
    return '${hours.toStringAsFixed(1)}h';
  }
}

// Course Detail Bottom Sheet
class _CourseDetailSheet extends ConsumerStatefulWidget {
  final CoursePack course;
  final String? currentUserId;
  final VoidCallback onClaim;
  final Color courseColor;
  final IconData courseIcon;

  const _CourseDetailSheet({
    required this.course,
    required this.onClaim,
    required this.courseColor,
    required this.courseIcon,
    this.currentUserId,
  });

  @override
  ConsumerState<_CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends ConsumerState<_CourseDetailSheet> {
  bool _isClaiming = false;
  bool _isCheckingClaimed = true;
  bool _alreadyClaimed = false;

  @override
  void initState() {
    super.initState();
    _checkIfClaimed();
  }

  Future<void> _checkIfClaimed() async {
    if (widget.currentUserId == null || isOwner) {
      setState(() => _isCheckingClaimed = false);
      return;
    }

    try {
      AppLogger.debug(
        'Checking if user ${widget.currentUserId} has claimed course ${widget.course.id}',
      );

      final claimed = await CoursePackService.hasUserClaimedCourse(
        widget.course.id,
        widget.currentUserId!,
      );

      AppLogger.debug(
        'Claimed status for course ${widget.course.id}: $claimed',
      );

      if (mounted) {
        setState(() {
          _alreadyClaimed = claimed;
          _isCheckingClaimed = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error checking claimed status: $e');
      if (mounted) {
        setState(() => _isCheckingClaimed = false);
      }
    }
  }

  bool get isOwner =>
      widget.currentUserId != null &&
      widget.course.ownerId == widget.currentUserId;

  Future<void> _handleClaim() async {
    if (_isClaiming || isOwner || _alreadyClaimed) return;

    setState(() => _isClaiming = true);

    try {
      AppLogger.info('Claiming course pack: ${widget.course.id}');

      final claimedCourseId = await CoursePackService.claimCoursePack(
        widget.course.id,
        widget.currentUserId!,
      );

      if (!mounted) return;

      AppLogger.success(
        'Course pack claimed successfully, new ID: $claimedCourseId',
      );

      setState(() {
        _alreadyClaimed = true;
        _isClaiming = false;
      });

      // Close the bottom sheet
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Course pack added to your library!')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Refresh the library provider to include the new item
      ref.invalidate(quizLibraryProvider);

      // Set the highlighted item (use the newly claimed course ID)
      ref
          .read(highlightedLibraryItemProvider.notifier)
          .setHighlightedItem(claimedCourseId);

      // Navigate to library tab (index 1)
      ref.read(bottomNavIndexProvider.notifier).setIndex(1);

      // Call the parent's onClaim to refresh the store list
      widget.onClaim();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isClaiming = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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
                      color: widget.courseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            widget.courseIcon,
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
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
                                  widget.course.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.course.name,
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

                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        value: widget.course.rating > 0
                            ? widget.course.rating.toStringAsFixed(1)
                            : 'New',
                        label: 'Rating',
                      ),
                      _buildStatItem(
                        icon: Icons.people_rounded,
                        iconColor: AppColors.primary,
                        value: _formatNumber(widget.course.enrolledCount),
                        label: 'Students',
                      ),
                      _buildStatItem(
                        icon: Icons.play_circle_rounded,
                        iconColor: AppColors.accentBright,
                        value: '${widget.course.videoLectures.length}',
                        label: 'Lessons',
                      ),
                      _buildStatItem(
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.secondary,
                        value: _formatDuration(widget.course.estimatedHours),
                        label: 'Duration',
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
                    widget.course.description.isNotEmpty
                        ? widget.course.description
                        : 'Master the fundamentals and advanced concepts with this comprehensive course. '
                              'This course is designed for learners who want to build a solid foundation and develop practical skills.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course Content Summary
                  const Text(
                    'What you\'ll get',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContentItem(
                    Icons.quiz_rounded,
                    '${widget.course.quizzes.length} Quizzes',
                  ),
                  _buildContentItem(
                    Icons.style_rounded,
                    '${widget.course.flashcardSets.length} Flashcard Sets',
                  ),
                  _buildContentItem(
                    Icons.note_rounded,
                    '${widget.course.notes.length} Notes',
                  ),
                  if (widget.course.videoLectures.isNotEmpty)
                    _buildContentItem(
                      Icons.videocam_rounded,
                      '${widget.course.videoLectures.length} Video Lectures',
                    ),

                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (isOwner ||
                              _alreadyClaimed ||
                              _isClaiming ||
                              _isCheckingClaimed)
                          ? null
                          : _handleClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isOwner || _alreadyClaimed)
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: (isOwner || _alreadyClaimed)
                            ? AppColors.textSecondary
                            : AppColors.primary.withValues(alpha: 0.6),
                      ),
                      child: _isCheckingClaimed
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : _isClaiming
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isOwner
                                      ? Icons.check_circle_outlined
                                      : _alreadyClaimed
                                      ? Icons.check_circle_rounded
                                      : Icons.add_to_photos_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isOwner
                                      ? 'You Own This'
                                      : _alreadyClaimed
                                      ? 'Already Claimed'
                                      : 'Claim Course',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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

  Widget _buildContentItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(double hours) {
    if (hours < 1) {
      // Convert to minutes and round to nearest 10
      final minutes = (hours * 60).round();
      final roundedMinutes = ((minutes / 10).round() * 10);
      return '${roundedMinutes}m';
    }
    // For 1 hour or more, show in hours
    return '${hours.toStringAsFixed(1)}h';
  }
}
