#!/usr/bin/env ruby
# encoding: UTF-8

require 'test_helper'

module CommonCore
  class LoaderTest < ActiveSupport::TestCase

    def setup
      Singleton.send(:__init__,Master)  #Force reinitialization
      @master = Master.instance
    end

    # math_standards
    test "should load standards from xml" do
      @master.load_elements_from_paths(DATA_PATH+'/Math.xml',DATA_PATH+'/ELA-Literacy.xml')
      assert_equal 966, @master.standards.keys.length
      @master.standards.each do |key,standard|
        assert standard.is_a?(Standard), "#{standard} expected to be a Standard"
        assert standard.valid?, "#{standard.error_message} - #{standard}"
      end
    end

    test "should load standard components from xml" do
      @master.load_elements_from_paths(DATA_PATH+'/Math.xml',DATA_PATH+'/ELA-Literacy.xml')
      assert_equal 569, @master.components.keys.length
      @master.components.each do |key,component|
        assert component.is_a?(Component), "#{component} expected to be a Component"
        assert component.valid?, "#{component.error_message} - #{component}"
      end
    end

    # math_domains
    test "should load a single math domain from xml" do
      @master.load_elements_from_paths(DATA_PATH+'/Mathematics/Grade1/Domain/Math_Grade1_G.xml')
      assert_equal 1, @master.domains.keys.length
      @master.domains.each do |key,domain|
        assert domain.is_a?(Domain), "#{domain} expected to be a Domain"
        assert domain.valid?, "#{domain} - #{domain.error_message}"
      end
    end

    # math_clusters
    test "should load a single math cluster from xml" do
      @master.load_elements_from_paths(DATA_PATH+'/Mathematics/Grade1/Domain/Clusters/Math_Grade1_G_1.xml')
      assert_equal 1, @master.clusters.keys.length
      @master.clusters.each do |key,cluster|
        assert cluster.is_a?(Cluster), "#{cluster} expected to be a Cluster"
        assert cluster.valid?, "#{cluster} - #{cluster.error_message}"
      end
    end

    test "should load all xml files for grade 1 math" do
      @master.load_elements_from_paths(DATA_PATH+'/Mathematics/Grade1/**/*.xml')
      assert_equal 1, @master.subject_grades.keys.length
      assert_equal 4, @master.domains.keys.length
      assert_equal 11, @master.clusters.keys.length
      @master.subject_grades.each do |key,subject_grade|
        assert subject_grade.is_a?(SubjectGrade), "#{subject_grade} expected to be a SubjectGrade"
        assert subject_grade.valid?, "#{subject_grade} - #{subject_grade.error_message}"
      end
      @master.domains.each do |key,domain|
        assert domain.is_a?(Domain), "#{domain} expected to be a Domain"
        assert domain.valid?, "#{domain} - #{domain.error_message}"
      end
      @master.clusters.each do |key,cluster|
        assert cluster.is_a?(Cluster), "#{cluster} expected to be a Cluster"
        assert cluster.valid?, "#{cluster} - #{cluster.error_message}"
      end
    end

    test "should load all xml files for math" do
      @master.load_elements_from_paths(DATA_PATH+'/Math.xml',DATA_PATH+'/Mathematics/**/*.xml')
      assert_equal 392, @master.standards.keys.length
      assert_equal 124, @master.components.keys.length
      assert_equal 15, @master.subject_grades.keys.length
      assert_equal 65, @master.domains.keys.length
      assert_equal 145, @master.clusters.keys.length
      @master.subject_grades.each do |key,subject_grade|
        assert subject_grade.is_a?(SubjectGrade), "#{subject_grade} expected to be a SubjectGrade"
        assert subject_grade.valid?, "#{subject_grade} - #{subject_grade.error_message}"
      end
      @master.domains.each do |key,domain|
        assert domain.is_a?(Domain), "#{domain} expected to be a Domain"
        assert domain.valid?, "#{domain} - #{domain.error_message}"
      end
      @master.clusters.each do |key,cluster|
        assert cluster.is_a?(Cluster), "#{cluster} expected to be a Cluster"
        assert cluster.valid?, "#{cluster} - #{cluster.error_message}"
      end
    end

    test "should load all xml files for language arts" do
      @master.load_elements_from_paths(DATA_PATH+'/ELA/**/*.xml')
      assert_equal 13, @master.subject_grades.keys.length
      assert_equal 74, @master.domains.keys.length
      assert_equal 1, @master.standard_types.keys.length
      @master.subject_grades.each do |key,subject_grade|
        assert subject_grade.is_a?(SubjectGrade), "#{subject_grade} expected to be a SubjectGrade"
        assert subject_grade.valid?, "#{subject_grade} - #{subject_grade.error_message}"
      end
      @master.domains.each do |key,domain|
        assert domain.is_a?(Domain), "#{domain} expected to be a Domain"
        assert domain.valid?, "#{domain} - #{domain.error_message}"
      end
      @master.standard_types.each do |key,standard_type|
        assert standard_type.is_a?(StandardType), "#{standard_type} expected to be a StandardType"
        assert standard_type.valid?,"#{standard_type} -#{standard_type.error_message}"
      end
    end

    test "should load all xml files for math and reunite parents with children" do
      @master.load_elements_from_paths(DATA_PATH+'/**/*.xml')
      orphan_elements = []
      @master.elements.each do |key,element|
        next unless (element.parent_ref_id and element.parent.nil?)
        next if element.parent_ref_id == 'INTENTIONALLYORPHANED'
        orphan_elements << element
      end
      assert_equal(0,orphan_elements.size, orphan_elements.map{|element| "#{element.class}:#{element.ref_id}"})
    end

    test 'math standards should have a cluster for a parent' do
      @master.load_elements_from_paths(DATA_PATH+'/Math.xml',DATA_PATH+'/Mathematics/**/*.xml')
      mismatched_standards = []
      @master.standards.each do |key,standard|
        next if standard.parent.is_a?(CommonCore::Cluster)
        next if standard.parent_ref_id == 'INTENTIONALLYORPHANED'
        mismatched_standards << standard
      end
      assert_equal(0,mismatched_standards.size, mismatched_standards.map{|standard| "#{standard.ref_id}:#{standard.parent.class}:#{standard.parent_ref_id}"})
    end

    test 'languange arts standards should have a cluster for a parent' do
      @master.load_elements_from_paths(DATA_PATH+'/ELA-Literacy.xml',DATA_PATH+'/ELA/**/*.xml')
      mismatched_standards = []
      @master.standards.each do |key,standard|
        next if standard.parent.is_a?(CommonCore::Domain)
        next if standard.parent_ref_id == 'INTENTIONALLYORPHANED'
        mismatched_standards << standard
      end
      assert_equal(0,mismatched_standards.size, mismatched_standards.map{|standard| "#{standard} === #{standard.parent_ref_id.blank?}=== #{standard.code.match(/CCSS\.ELA\-Literacy\.L\.3/)}"})
    end
  end
end