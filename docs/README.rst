.. _readme:

prometheus-formula
================

|img_travis| |img_sr|

.. |img_travis| image:: https://travis-ci.com/saltstack-formulas/prometheus-formula.svg?branch=master
   :alt: Travis CI Build Status
   :scale: 100%
   :target: https://travis-ci.com/saltstack-formulas/prometheus-formula
.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
Manage Prometheus on MacOS, GNU/Linux and FreeBSD.

.. contents:: **Table of Contents**

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

Contributing to this repo
-------------------------

Please see https://github.com/saltstack-formulas/prometheus-formula/blob/master/docs/CONTRIBUTING.rst

Available states
----------------

.. contents::
   :local:

``prometheus``
^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This installs the prometheus package,
manages the prometheus configuration file and then
starts the associated prometheus service.

``prometheus.archive``
^^^^^^^^^^^^^^^^^^^^

This state will install the prometheus from archive file only.

``prometheus.archive.alternatives``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will install the prometheus linux alternatives for archives only.

``prometheus.package``
^^^^^^^^^^^^^^^^^^^^

This state will install the prometheus package only.

``prometheus.package.repo``
^^^^^^^^^^^^^^^^^^^^^^^^^

This state will install the prometheus package only.

``prometheus.config``
^^^^^^^^^^^^^^^^^^^

This state will configure the prometheus service and has a dependency on ``prometheus.install``
via include list.

``prometheus.service``
^^^^^^^^^^^^^^^^^^^^

This state will start the prometheus service and has a dependency on ``prometheus.config``
via include list.

``prometheus.clean``
^^^^^^^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

this state will undo everything performed in the ``prometheus`` meta-state in reverse order, i.e.
stops the service,
removes the configuration file and
then uninstalls the package.

``prometheus.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will stop the prometheus service and disable it at boot time.

``prometheus.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the configuration of the prometheus service and has a
dependency on ``prometheus.service.clean`` via include list.

``prometheus.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the prometheus package and has a depency on
``prometheus.config.clean`` via include list.

``prometheus.package.archive.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will uninstall the prometheus archive-extracted directory only.

``prometheus.package.archive.alternatives.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will uninstall the prometheus linux alternatives for archives only.

``prometheus.package.repo.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^

This state will uninstall the prometheus upstream package repository only.
