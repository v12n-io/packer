#!/bin/bash
# Prepare Photon template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Build date used for motd
RELEASE=$(cat /etc/photon-release | head 1)
DOCS="https://github.com/v12n-io/packer"

# Create Issue
cat << ISSUE > /etc/issue

           {__   {__ {_            
{__     {__ {__ {_     {__{__ {__  
 {__   {__  {__      {__   {__  {__
  {__ {__   {__    {__     {__  {__
   {_{__    {__  {__       {__  {__
    {__    {____{________ {___  {__
        
        $RELEASE
        Build REPLACEWITHBUILDVERSION
        $DOCS

ISSUE

# MOTD symlinks
ln -sf /etc/issue /etc/issue.net