import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vidacoletiva/resources/assets/colour_pallete.dart';

enum RoleFilter { all, users, superadmins }

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  RoleFilter _filter = RoleFilter.all;
  Map<String, bool> _roles = {};
  bool _loadingRoles = false;
  final Set<String> _toggling = {};

  String _labelForFilter(RoleFilter f) {
    switch (f) {
      case RoleFilter.all:
        return 'Todos';
      case RoleFilter.users:
        return 'Apenas usuários';
      case RoleFilter.superadmins:
        return 'Apenas superadmins';
    }
  }

  Future<void> _setIsSuperAdmin(String uid, bool value) async {
    final doc = FirebaseFirestore.instance.doc('/users/$uid/private/private');
    await doc.set({'isSuperAdmin': value}, SetOptions(merge: true));
  }

  Future<void> _loadRolesForUids(List<String> uids) async {
    if (_loadingRoles) return;
    _loadingRoles = true;
    try {
      final refs = uids
          .map((u) =>
              FirebaseFirestore.instance.doc('/users/$u/private/private'))
          .toList();
      final futures = refs.map((r) => r.get()).toList();
      final snaps = await Future.wait(futures);
      final Map<String, bool> map = {};
      for (var s in snaps) {
        final parent = s.reference.parent.parent; // users/{uid}
        if (parent == null) continue;
        final uid = parent.id;
        if (!s.exists) {
          map[uid] = false;
        } else {
          final data = s.data();
          map[uid] = data != null && data['isSuperAdmin'] == true;
        }
      }
      if (!mounted) return;
      setState(() {
        _roles = map;
      });
    } catch (_) {
      // ignore errors for now
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoles = false;
        });
      } else {
        _loadingRoles = false;
      }
    }
  }

  bool _filterAccepts(bool isSuperAdmin) {
    if (_filter == RoleFilter.all) return true;
    if (_filter == RoleFilter.users) return !isSuperAdmin;
    return isSuperAdmin;
  }

  @override
  Widget build(BuildContext context) {
    // No provider usage required in this screen; checking current user via FirebaseAuth when needed.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderação — Usuários',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: AppColors.primaryOrange,
        actions: [
          PopupMenuButton<RoleFilter>(
            onSelected: (f) => setState(() => _filter = f),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: RoleFilter.all,
                  child: Text(_labelForFilter(RoleFilter.all))),
              PopupMenuItem(
                  value: RoleFilter.users,
                  child: Text(_labelForFilter(RoleFilter.users))),
              PopupMenuItem(
                  value: RoleFilter.superadmins,
                  child: Text(_labelForFilter(RoleFilter.superadmins))),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          // batch-load roles for all users currently in the snapshot
          final uids = docs.map((d) => d.id).toList();
          if (!_loadingRoles) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadRolesForUids(uids);
            });
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final uid = doc.id;
              final email = doc.data()['email'] ?? uid;

              final isAdmin = _roles.containsKey(uid) ? _roles[uid]! : false;

              if (!_filterAccepts(isAdmin)) return const SizedBox.shrink();

              final isSelf = FirebaseAuth.instance.currentUser?.uid == uid;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(email),
                  subtitle: Text(isAdmin ? 'Superadmin' : 'Usuário'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelf)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child:
                              Icon(Icons.person, size: 20, color: Colors.grey),
                        ),
                      if (_toggling.contains(uid))
                        const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator())
                      else
                        ElevatedButton.icon(
                          icon: Icon(
                              isAdmin ? Icons.shield : Icons.person_outline,
                              size: 18),
                          label: Text(isAdmin ? 'Superadmin' : 'Usuário'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            backgroundColor: isAdmin
                                ? Colors.green
                                : AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isSelf
                              ? null
                              : () async {
                                  final scaffold =
                                      ScaffoldMessenger.of(context);
                                  final want = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(isAdmin
                                          ? 'Rebaixar usuário'
                                          : 'Promover usuário'),
                                      content: Text(isAdmin
                                          ? 'Tem certeza que deseja rebaixar este superadmin para usuário?'
                                          : 'Tem certeza que deseja promover este usuário a superadmin?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Cancelar')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Confirmar')),
                                      ],
                                    ),
                                  );
                                  if (want != true) return;
                                  setState(() => _toggling.add(uid));
                                  try {
                                    await _setIsSuperAdmin(uid, !isAdmin);
                                    if (!mounted) return;
                                    setState(() {
                                      _roles[uid] = !isAdmin;
                                      _toggling.remove(uid);
                                    });
                                    scaffold.showSnackBar(SnackBar(
                                        content: Text(
                                            'Cargo atualizado para ${!isAdmin ? 'Superadmin' : 'Usuário'}')));
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _toggling.remove(uid));
                                    scaffold.showSnackBar(
                                        SnackBar(content: Text('Erro: $e')));
                                  }
                                },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
