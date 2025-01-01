import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/oauth_button.dart';
import 'package:primea/util/breakpoint.dart';
import 'package:primea/v2/match/deck_viewer.dart';
import 'package:primea/v2/match/labeled_value.dart';
import 'package:primea/v2/model/account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vector_graphics/vector_graphics.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Future<List<UserIdentity>> userIdentities =
      supabase.auth.getUserIdentities();

  Future<void> _linkIdentity(
      BuildContext context, OAuthProvider provider) async {
    try {
      await supabase.auth.linkIdentity(
        provider,
        redirectTo: kIsWeb ? "/auth/callback" : "world.primea://auth/callback",
      );
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Connected ${provider.name}",
              ),
              content: Text(
                "You have successfully connected your ${provider.name} account to Primea.World.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Failed to connect ${provider.name}",
              ),
              content: Text(
                "There was an error connecting to ${provider.name}. ${e.toString()}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _unlinkIdentity(
    BuildContext context,
    OAuthProvider provider,
    UserIdentity identity,
  ) async {
    try {
      final unlinkIdentity = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.warning,
              color: Colors.red,
            ),
            title: Text("Disconnect ${provider.name}"),
            content: Text(
              "Are you sure you want to disconnect your ${provider.name} account? You will not be able to login to Primea.World with ${provider.name} unless you reconnect your account.",
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              OutlinedButton.icon(
                label: const Text("Cancel"),
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FilledButton.icon(
                label: const Text("Disconnect"),
                icon: const Icon(Icons.delete),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (unlinkIdentity != null && unlinkIdentity) {
        await supabase.auth.unlinkIdentity(
          identity,
        );
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Disconnected ${provider.name}",
                ),
                content: Text(
                  "You have successfully disconnected your ${provider.name} account from Primea.World.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Failed to unlink ${provider.name}",
              ),
              content: Text(
                "There was an error unlinking to ${provider.name}. ${e.toString()}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = InheritedSession.of(context).session;
    final season = InheritedAccount.of(context).seasons.currentSeason;
    final decks = InheritedAccount.of(context).decks;
    return FutureBuilder(
      future: userIdentities,
      builder: (context, snapshot) {
        List<Widget> children;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            children = OAuthButton.providers.entries.map(
              (entry) {
                final provider = entry.key;
                final data = entry.value;
                return OutlinedButton.icon(
                  icon: Image.asset(data.icon, width: 24, height: 24),
                  label: Text(provider.name),
                  onPressed: null,
                );
              },
            ).toList();
          case ConnectionState.done:
            if (snapshot.hasError) {
              children = const [
                Text(
                  'Error loading identities. Please refresh the page.',
                )
              ];
            } else if (snapshot.hasData) {
              children = List.generate(
                OAuthButton.providers.length,
                (index) {
                  final provider = OAuthButton.providers.keys.elementAt(index);
                  final data = OAuthButton.providers[provider]!;
                  final identityIndex = snapshot.data!
                      .indexWhere((id) => id.provider == provider.name);

                  if (identityIndex == -1) {
                    return Padding(
                      padding: EdgeInsets.all(4),
                      child: OutlinedButton.icon(
                        icon: Image.asset(data.icon, width: 24, height: 24),
                        label: Text("Connect ${provider.name}"),
                        onPressed: () async {
                          await _linkIdentity(context, provider);
                        },
                      ),
                    );
                  } else {
                    final identity = snapshot.data![identityIndex];
                    return Padding(
                      padding: EdgeInsets.all(4),
                      child: FilledButton.icon(
                        label: Text(
                          identity.identityData?['name'] ??
                              identity.identityData?['email'] ??
                              provider.name,
                        ),
                        icon: Image.asset(data.icon, width: 24, height: 24),
                        onPressed: snapshot.data!.length <= 1
                            ? null
                            : () async {
                                await _unlinkIdentity(
                                  context,
                                  provider,
                                  snapshot.data![identityIndex],
                                );
                              },
                      ),
                    );
                  }
                },
                growable: false,
              );
            } else {
              children = OAuthButton.providers.entries.map(
                (entry) {
                  final provider = entry.key;
                  final data = entry.value;
                  return Padding(
                    padding: EdgeInsets.all(4),
                    child: OutlinedButton.icon(
                      icon: Image.asset(data.icon, width: 24, height: 24),
                      label: Text(provider.name),
                      onPressed: () async {
                        await _linkIdentity(context, provider);
                      },
                    ),
                  );
                },
              ).toList();
            }
        }
        return CustomScrollView(
          slivers: [
            DecoratedSliver(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: .5,
                  ),
                ),
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              width: .5,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: MediaQuery.of(context).size.width <
                              Breakpoint.desktop.width
                          ? 2
                          : 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 250,
                                minWidth: 175,
                              ),
                              padding: EdgeInsets.only(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                top: 48,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: .5,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  right: BorderSide(
                                    width: .5,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "PRIMEA",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withAlpha(125),
                                        ),
                                    textScaler: TextScaler.linear(.75),
                                  ),
                                  Text(
                                    "//",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withAlpha(125),
                                        ),
                                    textScaler: TextScaler.linear(.75),
                                  ),
                                ],
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
            SliverFixedExtentList.list(
              itemExtent: 250,
              children: [
                Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: Breakpoint.tablet.width - 120),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  blurRadius: 24,
                                  offset: Offset(0, 0),
                                  blurStyle: BlurStyle.solid,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.only(
                              left: 36,
                              top: 30,
                              right: 24,
                              bottom: 24,
                            ),
                            child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 16,
                                    right: 0,
                                    child: SvgPicture(
                                      width: 100,
                                      height: 100,
                                      AssetBytesLoader(
                                        "assets/parallel_logos/vec/${season?.parallel.title ?? 'universal'}.svg.vec",
                                      ),
                                      colorFilter: ColorFilter.mode(
                                        season?.parallel.color.withAlpha(150) ??
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(100),
                                        BlendMode.srcATop,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'USER: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall,
                                              ),
                                              TextSpan(
                                                text:
                                                    session?.user.userMetadata?[
                                                            'nickname'] ??
                                                        session?.user.email ??
                                                        "[UNKNOWN]",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              TextSpan(
                                                text: '\n',
                                              ),
                                              TextSpan(
                                                text: 'SEASON: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w100,
                                                    ),
                                              ),
                                              TextSpan(
                                                text:
                                                    season?.name ?? "[UNKNOWN]",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Table(
                                        children: [
                                          TableRow(
                                            children: [
                                              TableCell(
                                                child: LabeledValue(
                                                  label: "DECKS",
                                                  value: decks.iterable.length
                                                      .toString(),
                                                  borderColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w100,
                                                      ),
                                                  valueStyle: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall,
                                                ),
                                              ),
                                              TableCell(
                                                child: LabeledValue(
                                                  label: "RANK",
                                                  // TODO: Implement rank
                                                  value: "UNKNOWN",
                                                  borderColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w100,
                                                      ),
                                                  valueStyle: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed("/matches");
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: MediaQuery.of(context).size.width <
                                  Breakpoint.desktop.width
                              ? 2
                              : 3,
                          child: Container(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "PROTOCOL ONLINE",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(125),
                                        fontStyle: FontStyle.italic,
                                      ),
                                  textScaler: TextScaler.linear(.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: MediaQuery.of(context).size.width <
                                  Breakpoint.desktop.width
                              ? 2
                              : 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 250,
                                    minWidth: 175,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              blurRadius: 24,
                                              offset: Offset(0, 0),
                                              blurStyle: BlurStyle.outer,
                                            ),
                                          ],
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.network(
                                            'https://i.seadn.io/s/raw/files/4ca3d35011a5318ab2171bf137b0547f.png?auto=format&dpr=1&w=1000',
                                            colorBlendMode: BlendMode.dstATop,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withAlpha(35),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "UNKNOWN",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACCOUNT",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Connect your accounts to Primea.World to access your decks and matches from anywhere.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Wrap(
                      children: children,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PARALLEL",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Link your Parallel account to sync your game history.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    OutlinedButton(
                      child: Text("PARALLEL"),
                      onPressed: () async {
                        const responseType = "code";
                        const clientId =
                            "W7utv90Of68eG2QULZ4d2ChaHFwRmcTw5uLG6n5D";
                        // const redirectUrl =
                        //     kDebugMode ? "http://localhost:8080" : "/auth";
                        const redirectUrl = "/auth";
                        const generatedCode = "code";
                        const scopes = "pgs_user";
                        var uri = Uri.https(
                          "parallel.life",
                          "/oauth2/authorize",
                          {
                            "response_type": responseType,
                            "client_id": clientId,
                            "redirect_url": redirectUrl,
                            "code_challenge": generatedCode,
                            "scope": scopes
                          },
                        );
                        if (await canLaunchUrl(uri)) {
                          var launched = await launchUrl(
                            uri,
                            webOnlyWindowName: "_self",
                          );
                          if (!launched) {
                            throw 'Could not launch ${uri.toString()}';
                          }
                        } else {
                          throw 'Could not launch ${uri.toString()}';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(32),
              sliver: SliverGrid.extent(
                maxCrossAxisExtent: 250,
                children: decks.iterable.map(
                  (deck) {
                    return DeckViewer(
                      deck: deck,
                    );
                  },
                ).toList(),
              ),
            )
          ],
        );
      },
    );
  }
}
