import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/View/Screens/Login/Component/login_component.dart';
import 'package:education/View/Screens/Login/Component/register_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: DefaultTabController(
        length: 2,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: width < 380 ? 175 : 200,
              pinned: true,
              floating : true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: width < 380
                      ? const EdgeInsets.only(left: 16, right: 16, top: 30)
                      : const EdgeInsets.only(left: 32, right: 32, top: 60),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(width < 350 ? 8 : 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.secondary,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/education.svg',
                          width: width < 380 ? 36 : 45,
                          height: width < 380 ? 36 : 45,
                        ),
                      ),
                      SizedBox(height: width < 380 ? 8 : 14),
                      Text(
                        'Herkes İçin Eğitim',
                        style: GoogleFonts.inter(
                          color: AppColors.headTitleText,
                          fontSize: width < 380 ? 20 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width < 380 ? 8 : 14),
                      Text(
                        'Eğitimde fırsat eşitliği için bir araya geliyoruz. Hemen giriş yapın veya kaydolun!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: width < 380 ? 15 : 16,
                          fontWeight: FontWeight.normal,
                          color: AppColors.subTitleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: AppColors.activeChoose,
                  unselectedLabelColor: AppColors.darkGray,
                  indicatorColor: AppColors.activeChoose,
                  dividerColor: Colors.transparent,
                  unselectedLabelStyle: GoogleFonts.inter(
                    color: AppColors.darkGray,
                    fontSize: width < 380 ? 15 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  labelStyle: GoogleFonts.inter(
                    color: AppColors.activeChoose,
                    fontSize: width < 380 ? 15 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(
                      width: 2.0,
                      color: AppColors.activeChoose,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: width * 0.34),
                  ),
                  tabs: const [
                    Tab(text: 'Giriş Yap'),
                    Tab(text: 'Kayıt Ol'),
                  ],
                ),
              ),
            ),

            SliverFillRemaining(
              child: Container(
                color: AppColors.secondary,
                child: const TabBarView(
                  children: [
                    Login(),
                    Register(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
