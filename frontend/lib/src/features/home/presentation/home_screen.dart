import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/features/auth/data/auth_repository.dart';
import 'package:frontend/src/features/home/domain/listing_model.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Listing> _listings = const [
    Listing(
      id: '1',
      name: 'Rural Paradise Homestay',
      thumbnail:
          'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=400&q=80',
    ),
    Listing(
      id: '2',
      name: 'Countryside Retreat',
      thumbnail:
          'https://images.unsplash.com/photo-1712330138676-60e86456c218?w=400&q=80',
    ),
    Listing(
      id: '1',
      name: 'Rural Paradise Homestay',
      thumbnail:
          'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=400&q=80',
    ),
    Listing(
      id: '2',
      name: 'Countryside Retreat',
      thumbnail:
          'https://images.unsplash.com/photo-1712330138676-60e86456c218?w=400&q=80',
    ),
    Listing(
      id: '1',
      name: 'Rural Paradise Homestay',
      thumbnail:
          'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=400&q=80',
    ),
    Listing(
      id: '2',
      name: 'Countryside Retreat',
      thumbnail:
          'https://images.unsplash.com/photo-1712330138676-60e86456c218?w=400&q=80',
    ),
    Listing(
      id: '1',
      name: 'Rural Paradise Homestay',
      thumbnail:
          'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=400&q=80',
    ),
  ];

  Future<void> _signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userEmail = authRepository.userEmail ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(userEmail),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreateButton(),
                    const SizedBox(height: 28),
                    _buildListingsSection(),
                    const SizedBox(height: 28),
                    _buildQuickTips(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userEmail) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF059669),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'RumahGen',
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),

              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'EN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Logout button
              GestureDetector(
                onTap: _signOut,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w100,
            ),
          ),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/loading'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          disabledBackgroundColor: const Color(0xFFf97316).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 27),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        icon: Icon(Icons.add),
        label: const Text(
          'Create New Listing',
          style: TextStyle(
            fontSize: 21,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildListingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Your Listings',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0B),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_listings.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_listings.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: _listings
                .map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildListingCard(listing),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_rounded,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0A0A0B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first homestay listing',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(18),
            ),
            child: Image.network(
              listing.thumbnail,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 110,
                height: 110,
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),

          // Info & actions
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0A0B),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // Action buttons
                  Row(
                    children: [
                      _actionButton(
                        label: 'View',
                        icon: Icons.visibility_outlined,
                        onTap: () => context.go('/preview/${listing.id}'),
                        filled: false,
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        onTap: () => context.go('/create/${listing.id}'),
                        filled: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF059669) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: filled ? Colors.white : const Color(0xFF0A0A0B),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: filled ? Colors.white : const Color(0xFF0A0A0B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips() {
    const tips = [
      'Add clear photos to attract more guests',
      'Update listings regularly to stay visible',
      'Share your listings on social media',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECFDF5), Color(0xFFCCFBF1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1FAE5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Quick Tips',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A0A0B),
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
