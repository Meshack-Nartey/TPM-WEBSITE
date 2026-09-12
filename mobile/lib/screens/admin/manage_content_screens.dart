import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/books_api.dart';
import '../../services/branches_api.dart';
import '../../services/events_api.dart';
import '../../services/giving_channels_api.dart';
import '../../services/worker_groups_api.dart';
import 'content_manager.dart';

/// The five [ContentListScreen] configurations for the "office content"
/// tables — one factory each, called from the Manage screen.

Widget branchDirectoryScreen() => ContentListScreen<Branch>(
  title: 'Branches',
  eyebrow: "Pastor's Office",
  addLabel: 'Add a branch',
  icon: Icons.location_on_rounded,
  fields: const [
    ContentField(
      key: 'name',
      label: 'Name',
      hint: 'e.g. DAYSPRING',
      required: true,
    ),
    ContentField(
      key: 'region',
      label: 'Region',
      hint: 'e.g. Branch',
      required: true,
    ),
    ContentField(
      key: 'address',
      label: 'Address',
      hint: 'e.g. MC3V+2JF, Kumasi',
      required: true,
    ),
    ContentField(key: 'phone', label: 'Phone', hint: 'Optional'),
    ContentField(key: 'email', label: 'Email', hint: 'Optional'),
  ],
  fetch: (token) => BranchesApi(token: token).fetch(),
  idOf: (b) => b.id!,
  titleOf: (b) => b.name,
  subtitleOf: (b) => b.address,
  valuesOf: (b) => {
    'name': b.name,
    'region': b.region,
    'address': b.address,
    'phone': b.phone ?? '',
    'email': b.email ?? '',
  },
  create: (token, values) => BranchesApi(token: token).create(values),
  update: (token, id, values) => BranchesApi(token: token).update(id, values),
  delete: (token, id) => BranchesApi(token: token).delete(id),
);

Widget workerGroupDirectoryScreen() => ContentListScreen<WorkerGroup>(
  title: 'Worker groups',
  eyebrow: "Pastor's Office",
  addLabel: 'Add a worker group',
  icon: Icons.diversity_3_rounded,
  fields: const [
    ContentField(
      key: 'name',
      label: 'Name',
      hint: 'e.g. Ushering',
      required: true,
    ),
    ContentField(
      key: 'photo',
      label: 'Photo asset path',
      hint: 'e.g. assets/team/ushering.jpg',
      required: true,
    ),
    ContentField(
      key: 'blurb',
      label: 'Description',
      hint: 'What this group does',
      maxLines: 4,
      required: true,
    ),
  ],
  fetch: (token) => WorkerGroupsApi(token: token).fetch(),
  idOf: (g) => g.id!,
  titleOf: (g) => g.name,
  subtitleOf: (g) => g.blurb,
  valuesOf: (g) => {'name': g.name, 'photo': g.photo, 'blurb': g.blurb},
  create: (token, values) => WorkerGroupsApi(token: token).create(values),
  update: (token, id, values) =>
      WorkerGroupsApi(token: token).update(id, values),
  delete: (token, id) => WorkerGroupsApi(token: token).delete(id),
);

Widget givingChannelsScreen() => ContentListScreen<GivingChannel>(
  title: 'Giving channels',
  eyebrow: "Pastor's Office",
  addLabel: 'Add a giving channel',
  icon: Icons.payments_rounded,
  fields: const [
    ContentField(
      key: 'name',
      label: 'Name',
      hint: 'e.g. MTN Mobile Money',
      required: true,
    ),
    ContentField(
      key: 'logo',
      label: 'Logo asset path',
      hint: 'e.g. assets/give/mtn-momo.png',
      required: true,
    ),
    ContentField(
      key: 'accountName',
      label: 'Account name',
      hint: 'Whose account it is',
      required: true,
    ),
    ContentField(
      key: 'number',
      label: 'Number',
      hint: 'e.g. 055 447 6730',
      required: true,
    ),
    ContentField(
      key: 'numberLabel',
      label: 'Number label',
      hint: 'e.g. Pay ID, Number, Account Number',
      required: true,
    ),
  ],
  boolFields: const [ContentBoolField(key: 'isBank', label: 'Bank account')],
  fetch: (token) => GivingChannelsApi(token: token).fetch(),
  idOf: (c) => c.id!,
  titleOf: (c) => c.name,
  subtitleOf: (c) => '${c.numberLabel}: ${c.number}',
  valuesOf: (c) => {
    'name': c.name,
    'logo': c.logo,
    'accountName': c.accountName,
    'number': c.number,
    'numberLabel': c.numberLabel,
    'isBank': c.isBank,
  },
  create: (token, values) => GivingChannelsApi(token: token).create(values),
  update: (token, id, values) =>
      GivingChannelsApi(token: token).update(id, values),
  delete: (token, id) => GivingChannelsApi(token: token).delete(id),
);

Widget booksManageScreen() => ContentListScreen<Book>(
  title: 'Books & Resources',
  eyebrow: "Pastor's Office",
  addLabel: 'Add a book',
  icon: Icons.menu_book_rounded,
  fields: const [
    ContentField(
      key: 'title',
      label: 'Title',
      hint: 'e.g. Crossing the Red Sea',
      required: true,
    ),
    ContentField(
      key: 'author',
      label: 'Author',
      hint: 'e.g. TPM Discipleship',
      required: true,
    ),
    ContentField(
      key: 'cover',
      label: 'Cover asset path',
      hint: 'e.g. assets/books/red-sea.jpg',
      required: true,
    ),
  ],
  fetch: (token) => BooksApi(token: token).fetch(),
  idOf: (b) => b.id!,
  titleOf: (b) => b.title,
  subtitleOf: (b) => b.author,
  valuesOf: (b) => {'title': b.title, 'author': b.author, 'cover': b.cover},
  create: (token, values) => BooksApi(token: token).create(values),
  update: (token, id, values) => BooksApi(token: token).update(id, values),
  delete: (token, id) => BooksApi(token: token).delete(id),
);

Widget eventsManageScreen() => ContentListScreen<EventItem>(
  title: 'Events',
  eyebrow: "Pastor's Office",
  addLabel: 'Add an event',
  icon: Icons.event_rounded,
  fields: const [
    ContentField(
      key: 'title',
      label: 'Title',
      hint: 'e.g. Transformation Sunday',
      required: true,
    ),
    ContentField(
      key: 'tag',
      label: 'Tag',
      hint: 'e.g. Conference, Sunday',
      required: true,
    ),
    ContentField(
      key: 'location',
      label: 'Location',
      hint: 'e.g. All branches',
      required: true,
    ),
    ContentField(
      key: 'when',
      label: 'When',
      hint: 'e.g. Saturday 5th September · 8:00 AM',
      required: true,
    ),
    ContentField(
      key: 'day',
      label: 'Day badge',
      hint: 'e.g. 05 — optional, leave blank for TBA',
    ),
    ContentField(
      key: 'month',
      label: 'Month badge',
      hint: 'e.g. Sep — optional, leave blank for TBA',
    ),
    ContentField(
      key: 'description',
      label: 'Description',
      hint: 'What the event is about',
      maxLines: 4,
      required: true,
    ),
    ContentField(
      key: 'image',
      label: 'Flyer asset path',
      hint: 'e.g. assets/flyers/ts.png',
      required: true,
    ),
  ],
  fetch: (token) => EventsApi(token: token).fetch(),
  idOf: (e) => e.id!,
  titleOf: (e) => e.title,
  subtitleOf: (e) => e.when,
  valuesOf: (e) => {
    'title': e.title,
    'tag': e.tag,
    'location': e.location,
    'when': e.when,
    'day': e.day ?? '',
    'month': e.month ?? '',
    'description': e.description,
    'image': e.image,
  },
  create: (token, values) => EventsApi(token: token).create(values),
  update: (token, id, values) => EventsApi(token: token).update(id, values),
  delete: (token, id) => EventsApi(token: token).delete(id),
);
